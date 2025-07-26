import { 
  Connection, 
  PublicKey, 
  Transaction, 
  TransactionInstruction,
  SystemProgram,
  SYSVAR_RENT_PUBKEY,
  Keypair,
  sendAndConfirmTransaction,
  LAMPORTS_PER_SOL,
  sendAndConfirmTransaction as sendTransaction
} from '@solana/web3.js';
import { 
  TOKEN_PROGRAM_ID, 
  ASSOCIATED_TOKEN_PROGRAM_ID,
  getAssociatedTokenAddress,
  createAssociatedTokenAccountInstruction,
  createMintToInstruction,
  getAccount
} from '@solana/spl-token';
import { CONTRACT_ADDRESS } from './address';

// Program ID
export const PROGRAM_ID = new PublicKey(CONTRACT_ADDRESS);

// Token Metadata Program ID
const METADATA_PROGRAM_ID = new PublicKey('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');

// Helper function to get associated token address (like anchor.utils.token.associatedAddress)
async function getAssociatedTokenAddressAnchor(mint: PublicKey, owner: PublicKey): Promise<PublicKey> {
  return await getAssociatedTokenAddress(mint, owner);
}

// Interfaces for the contract
export interface CampaignData {
  id: string;
  mint: PublicKey;
  uri: string;
  agentCount: number;
  createdAt: number;
  bump: number;
}

export interface MintAccessNFTParams {
  campaignId: string;
  name: string;
  symbol: string;
  uri: string;
  agentCount: number;
  payer: PublicKey;
  mintAuthority: PublicKey;
  signTransaction: (transaction: Transaction) => Promise<Transaction>;
}

export interface VerifyAccessParams {
  campaignId: string;
  user: Keypair;
}

export interface UpdateCampaignDataParams {
  campaignId: string;
  authority: Keypair;
  newUri?: string;
  newAgentCount?: number;
}

export interface GetCampaignInfoParams {
  campaignId: string;
}

// Helper function to find PDA
export function findCampaignDataPDA(campaignId: string): [PublicKey, number] {
  return PublicKey.findProgramAddressSync(
    [Buffer.from('campaign'), Buffer.from(campaignId)],
    PROGRAM_ID
  );
}

// Helper function to find metadata PDA
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
 * Mint Access NFT with campaign metadata
 * This creates an NFT that serves as an access key for a specific campaign
 */
export async function mintAccessNFT(
  connection: Connection,
  params: MintAccessNFTParams
): Promise<string> {
  const {
    campaignId,
    name,
    symbol,
    uri,
    agentCount,
    payer,
    mintAuthority,
    signTransaction
  } = params;

  // Use the wallet's public key as the mint address (no keypair generation)
  const mintPublicKey = mintAuthority;
  
  // Find PDAs
  const [campaignDataPDA] = findCampaignDataPDA(campaignId);
  const [metadataPDA] = findMetadataPDA(mintPublicKey);
  
  // Get associated token account using our helper function
  const tokenAccount = await getAssociatedTokenAddressAnchor(mintPublicKey, mintAuthority);

  // Create the mint instruction data
  const mintData = Buffer.alloc(1 + campaignId.length + name.length + symbol.length + uri.length + 4);
  let offset = 0;
  mintData.writeUInt8(0, offset); // Instruction index for mint_access_nft
  offset += 1;
  mintData.write(campaignId, offset);
  offset += campaignId.length;
  mintData.write(name, offset);
  offset += name.length;
  mintData.write(symbol, offset);
  offset += symbol.length;
  mintData.write(uri, offset);
  offset += uri.length;
  mintData.writeUInt32LE(agentCount, offset);

  const mintIx = new TransactionInstruction({
    keys: [
      { pubkey: payer, isSigner: true, isWritable: true },
      { pubkey: mintAuthority, isSigner: true, isWritable: true },
      { pubkey: mintPublicKey, isSigner: false, isWritable: true },
      { pubkey: metadataPDA, isSigner: false, isWritable: true },
      { pubkey: tokenAccount, isSigner: false, isWritable: true },
      { pubkey: campaignDataPDA, isSigner: false, isWritable: true },
      { pubkey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
      { pubkey: ASSOCIATED_TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
      { pubkey: METADATA_PROGRAM_ID, isSigner: false, isWritable: false },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
      { pubkey: SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false },
    ],
    programId: PROGRAM_ID,
    data: mintData
  });

  // Create transaction
  const transaction = new Transaction();
  transaction.add(mintIx);
  
  // Get recent blockhash
  const { blockhash } = await connection.getLatestBlockhash();
  transaction.recentBlockhash = blockhash;
  transaction.feePayer = payer;

  // Sign with wallet only (no mint keypair)
  const signedTransaction = await signTransaction(transaction);

  // Send transaction
  const signature = await connection.sendRawTransaction(signedTransaction.serialize(), {
    skipPreflight: false,
    preflightCommitment: 'confirmed'
  });

  // Wait for confirmation
  await connection.confirmTransaction(signature, 'confirmed');

  console.log('Transaction successful! Hash:', signature);
  console.log('Mint address:', mintPublicKey.toString());
  console.log('Campaign data address:', campaignDataPDA.toString());
  console.log('Campaign ID:', campaignId);
  console.log('View on Solana Explorer:', `https://explorer.solana.com/tx/${signature}?cluster=devnet`);

  return signature;
}

/**
 * Verify user has access to a specific campaign
 * This function checks if the user owns the required NFT
 */
export async function verifyAccess(
  connection: Connection,
  params: VerifyAccessParams
): Promise<boolean> {
  const { campaignId, user } = params;

  // Find PDAs
  const [campaignDataPDA] = findCampaignDataPDA(campaignId);
  
  // Get campaign data
  const campaignDataAccount = await connection.getAccountInfo(campaignDataPDA);
  if (!campaignDataAccount) {
    throw new Error('Campaign not found');
  }

  // Parse campaign data to get mint
  const campaignData = parseCampaignData(campaignDataAccount.data);
  
  // Get user's token account
  const userTokenAccount = await getAssociatedTokenAddressAnchor(
    campaignData.mint,
    user.publicKey
  );

  // Check if user has the token
  try {
    const tokenAccount = await getAccount(connection, userTokenAccount);
    if (tokenAccount.amount < 1) {
      return false;
    }
  } catch (error) {
    return false; // Token account doesn't exist or user doesn't have the token
  }

  // Create verify access instruction
  const verifyData = Buffer.alloc(1 + campaignId.length);
  verifyData.writeUInt8(1, 0); // Instruction index for verify_access
  verifyData.write(campaignId, 1);

  const verifyIx = new TransactionInstruction({
    keys: [
      { pubkey: user.publicKey, isSigner: true, isWritable: false },
      { pubkey: userTokenAccount, isSigner: false, isWritable: false },
      { pubkey: campaignDataPDA, isSigner: false, isWritable: false },
    ],
    programId: PROGRAM_ID,
    data: verifyData
  });

  // Create and send transaction
  const transaction = new Transaction();
  transaction.add(verifyIx);

  try {
    await sendAndConfirmTransaction(
      connection,
      transaction,
      [user],
      { commitment: 'confirmed' }
    );
    return true;
  } catch (error) {
    console.error('Access verification failed:', error);
    return false;
  }
}

/**
 * Update campaign metadata (only by original mint authority)
 */
export async function updateCampaignData(
  connection: Connection,
  params: UpdateCampaignDataParams
): Promise<string> {
  const { campaignId, authority, newUri, newAgentCount } = params;

  // Find PDAs
  const [campaignDataPDA] = findCampaignDataPDA(campaignId);
  
  // Get campaign data to find mint
  const campaignDataAccount = await connection.getAccountInfo(campaignDataPDA);
  if (!campaignDataAccount) {
    throw new Error('Campaign not found');
  }

  const campaignData = parseCampaignData(campaignDataAccount.data);

  // Create update instruction
  const updateDataLength = 1 + campaignId.length + (newUri ? newUri.length : 0) + (newAgentCount ? 4 : 0);
  const updateData = Buffer.alloc(updateDataLength);
  let updateOffset = 0;
  updateData.writeUInt8(2, updateOffset); // Instruction index for update_campaign_data
  updateOffset += 1;
  updateData.write(campaignId, updateOffset);
  updateOffset += campaignId.length;
  if (newUri) {
    updateData.write(newUri, updateOffset);
    updateOffset += newUri.length;
  }
  if (newAgentCount) {
    updateData.writeUInt32LE(newAgentCount, updateOffset);
  }

  const updateIx = new TransactionInstruction({
    keys: [
      { pubkey: authority.publicKey, isSigner: true, isWritable: true },
      { pubkey: campaignDataPDA, isSigner: false, isWritable: true },
      { pubkey: campaignData.mint, isSigner: false, isWritable: false },
    ],
    programId: PROGRAM_ID,
    data: updateData
  });

  // Create and send transaction
  const transaction = new Transaction();
  transaction.add(updateIx);

  const signature = await sendAndConfirmTransaction(
    connection,
    transaction,
    [authority],
    { commitment: 'confirmed' }
  );

  return signature;
}

/**
 * Get campaign information
 */
export async function getCampaignInfo(
  connection: Connection,
  params: GetCampaignInfoParams
): Promise<CampaignData> {
  const { campaignId } = params;

  // Find PDA
  const [campaignDataPDA] = findCampaignDataPDA(campaignId);
  
  // Get campaign data
  const campaignDataAccount = await connection.getAccountInfo(campaignDataPDA);
  if (!campaignDataAccount) {
    throw new Error('Campaign not found');
  }

  return parseCampaignData(campaignDataAccount.data);
}

/**
 * Parse campaign data from account buffer
 */
function parseCampaignData(data: Buffer): CampaignData {
  // Skip discriminator (8 bytes)
  let offset = 8;
  
  // Read id (String)
  const idLength = data.readUInt32LE(offset);
  offset += 4;
  const id = data.slice(offset, offset + idLength).toString('utf8');
  offset += idLength;
  
  // Read mint (Pubkey - 32 bytes)
  const mint = new PublicKey(data.slice(offset, offset + 32));
  offset += 32;
  
  // Read uri (String)
  const uriLength = data.readUInt32LE(offset);
  offset += 4;
  const uri = data.slice(offset, offset + uriLength).toString('utf8');
  offset += uriLength;
  
  // Read agent_count (u32 - 4 bytes)
  const agentCount = data.readUInt32LE(offset);
  offset += 4;
  
  // Read created_at (i64 - 8 bytes)
  const createdAt = Number(data.readBigUInt64LE(offset));
  offset += 8;
  
  // Read bump (u8 - 1 byte)
  const bump = data.readUInt8(offset);
  
  return {
    id,
    mint,
    uri,
    agentCount,
    createdAt,
    bump,
  };
}

/**
 * Get all campaigns for a user
 */
export async function getUserCampaigns(
  connection: Connection,
  userPublicKey: PublicKey
): Promise<CampaignData[]> {
  // This would require additional indexing or querying
  // For now, we'll return an empty array
  // In a real implementation, you might want to:
  // 1. Store campaign IDs in a separate account
  // 2. Use a database to track user-campaign relationships
  // 3. Query all token accounts for the user and filter by program
  return [];
}

/**
 * Check if user has access to a specific campaign
 */
export async function checkUserAccess(
  connection: Connection,
  userPublicKey: PublicKey,
  campaignId: string
): Promise<boolean> {
  try {
    // Get campaign data
    const campaignData = await getCampaignInfo(connection, { campaignId });
    
    // Get user's token account
    const userTokenAccount = await getAssociatedTokenAddressAnchor(
      campaignData.mint,
      userPublicKey
    );

    // Check if user has the token
    const tokenAccount = await getAccount(connection, userTokenAccount);
    return tokenAccount.amount >= 1;
  } catch (error) {
    return false;
  }
}
