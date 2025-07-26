use anchor_lang::prelude::*;
use anchor_spl::{
    associated_token::AssociatedToken,
    token::{Mint, Token, TokenAccount, MintTo, mint_to},
    metadata::{create_metadata_accounts_v3, CreateMetadataAccountsV3, Metadata, mpl_token_metadata},
};
use mpl_token_metadata::{
    types::{DataV2, Creator, CollectionDetails},
};

declare_id!("Gi5Mqc3S5qmPB7WUMtqchXyEKZHH3N7GhLbvTRtbbeUZ");

#[program]
pub mod access_nft {
    use super::*;

    /// Mint Access NFT with campaign metadata
    /// This creates an NFT that serves as an access key for a specific campaign
    pub fn mint_access_nft(
        ctx: Context<MintAccessNFT>,
        campaign_id: String,
        name: String,
        symbol: String,
        uri: String,
        agent_count: u32,
    ) -> Result<()> {
        msg!("Minting Access NFT for campaign: {}", campaign_id);

        // Create the NFT metadata using Metaplex standard
        let creator = vec![Creator {
            address: ctx.accounts.mint_authority.key(),
            verified: true,
            share: 100,
        }];

        let data_v2 = DataV2 {
            name: name.clone(),
            symbol: symbol.clone(),
            uri: uri.clone(),
            seller_fee_basis_points: 500, // 5% royalty
            creators: Some(creator),
            collection: None,
            uses: None,
        };

        // Create metadata account through Metaplex
        create_metadata_accounts_v3(
            CpiContext::new(
                ctx.accounts.token_metadata_program.to_account_info(),
                CreateMetadataAccountsV3 {
                    metadata: ctx.accounts.metadata.to_account_info(),
                    mint: ctx.accounts.mint.to_account_info(),
                    mint_authority: ctx.accounts.mint_authority.to_account_info(),
                    update_authority: ctx.accounts.mint_authority.to_account_info(),
                    payer: ctx.accounts.payer.to_account_info(),
                    system_program: ctx.accounts.system_program.to_account_info(),
                    rent: ctx.accounts.rent.to_account_info(),
                },
            ),
            data_v2,
            true, // is_mutable
            true, // update_authority_is_signer
            Some(CollectionDetails::V1 { size: 0 }),
        )?;

        // Mint exactly 1 token to the recipient
        mint_to(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                MintTo {
                    mint: ctx.accounts.mint.to_account_info(),
                    to: ctx.accounts.token_account.to_account_info(),
                    authority: ctx.accounts.mint_authority.to_account_info(),
                },
            ),
            1, // Amount: exactly 1 NFT
        )?;

        // Store campaign data on-chain
        let campaign_data = &mut ctx.accounts.campaign_data;
        campaign_data.id = campaign_id;
        campaign_data.mint = ctx.accounts.mint.key();
        campaign_data.uri = uri;
        campaign_data.agent_count = agent_count;
        campaign_data.created_at = Clock::get()?.unix_timestamp;
        campaign_data.bump = ctx.bumps.campaign_data;

        msg!("Access NFT minted successfully for campaign: {}", campaign_data.id);
        Ok(())
    }

    /// Verify user has access to a specific campaign
    /// This function checks if the user owns the required NFT
    pub fn verify_access(
        ctx: Context<VerifyAccess>,
        _campaign_id: String,
    ) -> Result<()> {
        let token_amount = ctx.accounts.user_token_account.amount;
        
        require!(token_amount >= 1, AccessError::InsufficientTokens);
        
        msg!("Access verified for campaign: {} by user: {}", 
             ctx.accounts.campaign_data.id, 
             ctx.accounts.user.key());
        
        Ok(())
    }

    /// Update campaign metadata (only by original mint authority)
    pub fn update_campaign_data(
        ctx: Context<UpdateCampaignData>,
        new_uri: Option<String>,
        new_agent_count: Option<u32>,
    ) -> Result<()> {
        let campaign_data = &mut ctx.accounts.campaign_data;
        
        if let Some(uri) = new_uri {
            campaign_data.uri = uri;
        }
        
        if let Some(count) = new_agent_count {
            campaign_data.agent_count = count;
        }
        
        msg!("Campaign data updated for: {}", campaign_data.id);
        Ok(())
    }

    /// Get campaign information
    pub fn get_campaign_info(
        ctx: Context<GetCampaignInfo>,
        _campaign_id: String,
    ) -> Result<()> {
        let campaign_data = &ctx.accounts.campaign_data;
        
        msg!("Campaign ID: {}", campaign_data.id);
        msg!("Mint: {}", campaign_data.mint);
        msg!("URI: {}", campaign_data.uri);
        msg!("Agent Count: {}", campaign_data.agent_count);
        msg!("Created At: {}", campaign_data.created_at);
        
        Ok(())
    }
}

// ========== ACCOUNT STRUCTS ==========

#[derive(Accounts)]
#[instruction(campaign_id: String, name: String, symbol: String, uri: String)]
pub struct MintAccessNFT<'info> {
    /// Payer and mint authority
    #[account(mut)]
    pub payer: Signer<'info>,
    
    /// Mint authority for the NFT
    #[account(mut)]
    pub mint_authority: Signer<'info>,
    
    /// The mint account for this NFT
    #[account(
        init,
        payer = payer,
        mint::decimals = 0,
        mint::authority = mint_authority,
        mint::freeze_authority = mint_authority,
    )]
    pub mint: Account<'info, Mint>,
    
    /// Metadata account (PDA derived from mint)
    /// CHECK: This account is checked by Metaplex
    #[account(
        mut,
        seeds = [
            b"metadata",
            token_metadata_program.key().as_ref(),
            mint.key().as_ref()
        ],
        seeds::program = token_metadata_program.key(),
        bump
    )]
    pub metadata: UncheckedAccount<'info>,
    
    /// Token account to receive the NFT
    #[account(
        init,
        payer = payer,
        associated_token::mint = mint,
        associated_token::authority = mint_authority,
    )]
    pub token_account: Account<'info, TokenAccount>,
    
    /// Campaign data PDA
    #[account(
        init,
        payer = payer,
        space = CampaignData::LEN,
        seeds = [b"campaign", campaign_id.as_bytes()],
        bump
    )]
    pub campaign_data: Account<'info, CampaignData>,
    
    /// Required programs
    pub token_program: Program<'info, Token>,
    pub associated_token_program: Program<'info, AssociatedToken>,
    pub token_metadata_program: Program<'info, Metadata>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
#[instruction(campaign_id: String)]
pub struct VerifyAccess<'info> {
    /// User requesting access
    pub user: Signer<'info>,
    
    /// User's token account containing the access NFT
    #[account(
        associated_token::mint = campaign_data.mint,
        associated_token::authority = user,
        constraint = user_token_account.amount >= 1 @ AccessError::InsufficientTokens
    )]
    pub user_token_account: Account<'info, TokenAccount>,
    
    /// Campaign data PDA
    #[account(
        seeds = [b"campaign", campaign_id.as_bytes()],
        bump = campaign_data.bump,
    )]
    pub campaign_data: Account<'info, CampaignData>,
}

#[derive(Accounts)]
#[instruction(campaign_id: String)]
pub struct UpdateCampaignData<'info> {
    /// Authority that can update (must be original mint authority)
    #[account(mut)]
    pub authority: Signer<'info>,
    
    /// Campaign data PDA
    #[account(
        mut,
        seeds = [b"campaign", campaign_id.as_bytes()],
        bump = campaign_data.bump,
    )]
    pub campaign_data: Account<'info, CampaignData>,
    
    /// The mint account (for verification)
    #[account(
        constraint = mint.mint_authority.unwrap() == authority.key() @ AccessError::UnauthorizedUpdate
    )]
    pub mint: Account<'info, Mint>,
}

#[derive(Accounts)]
#[instruction(campaign_id: String)]
pub struct GetCampaignInfo<'info> {
    /// Campaign data PDA
    #[account(
        seeds = [b"campaign", campaign_id.as_bytes()],
        bump = campaign_data.bump,
    )]
    pub campaign_data: Account<'info, CampaignData>,
}

// ========== DATA STRUCTURES ==========

#[account]
pub struct CampaignData {
    /// Unique campaign identifier
    pub id: String,          // 32 bytes max
    /// The mint address of the access NFT
    pub mint: Pubkey,        // 32 bytes
    /// IPFS URI or metadata URI
    pub uri: String,         // 200 bytes max
    /// Number of agents in the campaign
    pub agent_count: u32,    // 4 bytes
    /// Unix timestamp of creation
    pub created_at: i64,     // 8 bytes
    /// PDA bump seed
    pub bump: u8,            // 1 byte
}

impl CampaignData {
    pub const LEN: usize = 8 + // discriminator
        4 + 32 +              // id (String)
        32 +                  // mint (Pubkey)
        4 + 200 +             // uri (String)
        4 +                   // agent_count (u32)
        8 +                   // created_at (i64)
        1;                    // bump (u8)
}

// ========== ERRORS ==========

#[error_code]
pub enum AccessError {
    #[msg("Insufficient tokens for access")]
    InsufficientTokens,
    #[msg("Unauthorized to update campaign data")]
    UnauthorizedUpdate,
    #[msg("Invalid campaign ID")]
    InvalidCampaignId,
    #[msg("Campaign not found")]
    CampaignNotFound,
}