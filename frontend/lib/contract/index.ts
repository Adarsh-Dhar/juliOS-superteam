import { Program, AnchorProvider, Idl } from '@coral-xyz/anchor';
import { Connection, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY, Keypair } from '@solana/web3.js';
import { AnchorWallet } from '@solana/wallet-adapter-react';
import { ASSOCIATED_TOKEN_PROGRAM_ID, TOKEN_PROGRAM_ID, getAssociatedTokenAddress } from '@solana/spl-token';
import idl from './access_nft.json';
import { CONTRACT_ADDRESS } from './address';

// Your program ID
export const PROGRAM_ID = new PublicKey(CONTRACT_ADDRESS);

// Token Metadata Program ID
export const TOKEN_METADATA_PROGRAM_ID = new PublicKey('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');

// Create program instance
export const getProgram = (connection: Connection, wallet: AnchorWallet) => {
  const provider = new AnchorProvider(connection, wallet, {
    commitment: 'confirmed',
  });

  return new Program(idl as Idl, provider);
};

// Helper function to get associated token address
export const getAssociatedTokenAddressHelper = async (mint: PublicKey, owner: PublicKey) => {
  return await getAssociatedTokenAddress(mint, owner);
};

// Helper function to find campaign data PDA
export const findCampaignDataPDA = (campaignId: string, programId: PublicKey): [PublicKey, number] => {
  return PublicKey.findProgramAddressSync(
    [Buffer.from('campaign'), Buffer.from(campaignId)],
    programId
  );
};

// Helper function to find metadata PDA
export const findMetadataPDA = (mint: PublicKey): [PublicKey, number] => {
  return PublicKey.findProgramAddressSync(
    [
      Buffer.from('metadata'),
      TOKEN_METADATA_PROGRAM_ID.toBuffer(),
      mint.toBuffer(),
    ],
    TOKEN_METADATA_PROGRAM_ID
  );
};

export const mintAccessNFT = async (
  program: any, 
  wallet: AnchorWallet, 
  campaignId: string, 
  name: string, 
  symbol: string, 
  uri: string, 
  agentCount: number
) => {
  const mintKP = Keypair.generate();
  
  const [metadataPDA] = findMetadataPDA(mintKP.publicKey);
  const tokenAccountPDA = await getAssociatedTokenAddressHelper(mintKP.publicKey, wallet.publicKey);
  const [campaignDataPDA] = findCampaignDataPDA(campaignId, program.programId);

  try {
    const tx = await program.methods
      .mintAccessNft(campaignId, name, symbol, uri, agentCount)
      .accounts({
        payer: wallet.publicKey,
        mintAuthority: wallet.publicKey,
        mint: mintKP.publicKey,
        metadata: metadataPDA,
        tokenAccount: tokenAccountPDA,
        campaignData: campaignDataPDA,
        tokenProgram: TOKEN_PROGRAM_ID,
        associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
        tokenMetadataProgram: TOKEN_METADATA_PROGRAM_ID,
        systemProgram: SystemProgram.programId,
        rent: SYSVAR_RENT_PUBKEY,
      })
      .signers([mintKP])
      .rpc();

    console.log('Mint executed successfully:', tx);
    return tx;
  } catch (error) {
    console.error('Error minting NFT:', error);
    throw error;
  }
};

// Verify user access to a campaign
export const verifyAccess = async (
  program: any,
  wallet: AnchorWallet,
  campaignId: string
) => {
  const [campaignDataPDA] = findCampaignDataPDA(campaignId, program.programId);
  
  // Get campaign data to find the mint
  const campaignData = await program.account.campaignData.fetch(campaignDataPDA);
  const mint = campaignData.mint;
  
  const userTokenAccount = await getAssociatedTokenAddressHelper(mint, wallet.publicKey);

  try {
    const tx = await program.methods
      .verifyAccess(campaignId)
      .accounts({
        user: wallet.publicKey,
        userTokenAccount: userTokenAccount,
        campaignData: campaignDataPDA,
      })
      .rpc();

    console.log('Access verified successfully:', tx);
    return true;
  } catch (error) {
    console.error('Access verification failed:', error);
    return false;
  }
};

// Get campaign information
export const getCampaignInfo = async (
  program: any,
  campaignId: string
) => {
  const [campaignDataPDA] = findCampaignDataPDA(campaignId, program.programId);

  try {
    const campaignData = await program.account.campaignData.fetch(campaignDataPDA);
    return campaignData;
  } catch (error) {
    console.error('Failed to get campaign info:', error);
    throw error;
  }
};