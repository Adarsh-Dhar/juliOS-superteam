import { Program, AnchorProvider, web3, BN, Idl } from '@coral-xyz/anchor';
import { Connection, PublicKey, Keypair } from '@solana/web3.js';
import { CONTRACT_ADDRESS } from './address';
import idl from './access_nft.json';

// Program ID
export const PROGRAM_ID = new PublicKey(CONTRACT_ADDRESS);

// Token Metadata Program ID
export const METADATA_PROGRAM_ID = new PublicKey('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');

// Type for the program - using any to avoid complex type issues
export type AccessNFT = Program<any>;

/**
 * Initialize the Anchor program client
 */
export function getProgram(connection: Connection, wallet: any): AccessNFT {
  const provider = new AnchorProvider(connection, wallet, {
    commitment: 'confirmed',
    preflightCommitment: 'confirmed',
  });
  
  return new Program(idl as Idl, provider);
}

/**
 * Helper function to find campaign data PDA
 */
export function findCampaignDataPDA(campaignId: string): [PublicKey, number] {
  return PublicKey.findProgramAddressSync(
    [Buffer.from('campaign'), Buffer.from(campaignId)],
    PROGRAM_ID
  );
}

/**
 * Helper function to find metadata PDA
 */
export function findMetadataPDA(mint: PublicKey): [PublicKey, number] {
  return PublicKey.findProgramAddressSync(
    [
      Buffer.from('metadata'),
      METADATA_PROGRAM_ID.toBuffer(),
      mint.toBuffer(),
    ],
    METADATA_PROGRAM_ID
  );
}

/**
 * Get associated token address
 */
export async function getAssociatedTokenAddress(mint: PublicKey, owner: PublicKey): Promise<PublicKey> {
  const { getAssociatedTokenAddress } = await import('@solana/spl-token');
  return await getAssociatedTokenAddress(mint, owner);
} 