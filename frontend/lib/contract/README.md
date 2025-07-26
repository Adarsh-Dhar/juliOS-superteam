# Solana Contract Functions

This directory contains the frontend functions for interacting with the Solana access NFT contract. The contract allows users to mint access NFTs for campaigns and verify access to those campaigns.

## Contract Address

The contract is deployed at: `8B6KZ6y2F949x5XJYyYbkhGpTGxgd9j7riskn4EsMet4`

## Functions

### 1. `mintAccessNFT`

Mints an access NFT for a specific campaign using the connected wallet.

```typescript
import { mintAccessNFT } from '@/lib/contract';

const signature = await mintAccessNFT(connection, {
  campaignId: "campaign-123",
  name: "Access NFT",
  symbol: "ACCESS",
  uri: "https://example.com/metadata.json",
  agentCount: 5,
  payer: wallet.publicKey,
  mintAuthority: wallet.publicKey,
  signTransaction: wallet.signTransaction,
});
```

**Parameters:**
- `connection`: Solana connection object
- `campaignId`: Unique identifier for the campaign
- `name`: NFT name
- `symbol`: NFT symbol
- `uri`: Metadata URI
- `agentCount`: Number of agents in the campaign
- `payer`: Public key of the wallet paying transaction fees
- `mintAuthority`: Public key of the wallet with mint authority
- `signTransaction`: Function to sign the transaction with the connected wallet

**Returns:** Transaction signature string

### 2. `verifyAccess`

Verifies if a user has access to a specific campaign by checking if they own the required NFT.

```typescript
import { verifyAccess } from '@/lib/contract';

const hasAccess = await verifyAccess(connection, {
  campaignId: "campaign-123",
  user: wallet.publicKey,
  signTransaction: wallet.signTransaction,
});
```

**Parameters:**
- `connection`: Solana connection object
- `campaignId`: Campaign identifier
- `user`: Public key of the user to verify
- `signTransaction`: Function to sign the transaction with the connected wallet

**Returns:** Boolean indicating access status

### 3. `updateCampaignData`

Updates campaign metadata (only by original mint authority).

```typescript
import { updateCampaignData } from '@/lib/contract';

const signature = await updateCampaignData(connection, {
  campaignId: "campaign-123",
  authority: wallet.publicKey,
  signTransaction: wallet.signTransaction,
  newUri: "https://example.com/new-metadata.json", // optional
  newAgentCount: 10, // optional
});
```

**Parameters:**
- `connection`: Solana connection object
- `campaignId`: Campaign identifier
- `authority`: Public key of the authority (must be original mint authority)
- `signTransaction`: Function to sign the transaction with the connected wallet
- `newUri`: New metadata URI (optional)
- `newAgentCount`: New agent count (optional)

**Returns:** Transaction signature string

### 4. `getCampaignInfo`

Retrieves campaign information from the blockchain.

```typescript
import { getCampaignInfo } from '@/lib/contract';

const campaignData = await getCampaignInfo(connection, {
  campaignId: "campaign-123",
});
```

**Parameters:**
- `connection`: Solana connection object
- `campaignId`: Campaign identifier

**Returns:** CampaignData object

### 5. `checkUserAccess`

Checks if a specific user has access to a campaign without requiring a transaction.

```typescript
import { checkUserAccess } from '@/lib/contract';

const hasAccess = await checkUserAccess(connection, userPublicKey, "campaign-123");
```

**Parameters:**
- `connection`: Solana connection object
- `userPublicKey`: User's public key
- `campaignId`: Campaign identifier

**Returns:** Boolean indicating access status

### 6. `getUserCampaigns`

Gets all campaigns for a specific user (placeholder implementation).

```typescript
import { getUserCampaigns } from '@/lib/contract';

const campaigns = await getUserCampaigns(connection, userPublicKey);
```

**Parameters:**
- `connection`: Solana connection object
- `userPublicKey`: User's public key

**Returns:** Array of CampaignData objects

## Data Structures

### CampaignData

```typescript
interface CampaignData {
  id: string;           // Campaign identifier
  mint: PublicKey;      // NFT mint address
  uri: string;          // Metadata URI
  agentCount: number;   // Number of agents
  createdAt: number;    // Creation timestamp
  bump: number;         // PDA bump seed
}
```

## React Hook

For easier integration with React components, use the `useContract` hook:

```typescript
import { useContract } from '@/hooks/useContract';
import { useWallet } from '@solana/wallet-adapter-react';

function MyComponent() {
  const connection = new Connection('https://api.devnet.solana.com');
  const { publicKey, signTransaction } = useWallet();
  const { 
    loading, 
    error, 
    mintNFT, 
    verifyUserAccess, 
    updateCampaign, 
    getCampaign, 
    checkAccess,
    clearError 
  } = useContract(connection);

  const handleMint = async () => {
    if (!publicKey || !signTransaction) return;
    
    const signature = await mintNFT({
      campaignId: "campaign-123",
      name: "Access NFT",
      symbol: "ACCESS",
      uri: "https://example.com/metadata.json",
      agentCount: 5,
      payer: publicKey,
      mintAuthority: publicKey,
      signTransaction,
    });
    
    if (signature) {
      console.log('NFT minted:', signature);
    }
  };

  return (
    <div>
      {loading && <p>Loading...</p>}
      {error && <p>Error: {error}</p>}
      <button onClick={handleMint}>Mint NFT</button>
    </div>
  );
}
```

## Example Component

See `components/ContractExample.tsx` for a complete example of how to use all the contract functions with a beautiful UI.

## Error Handling

All functions include proper error handling:

- Network errors are caught and returned as error messages
- Invalid parameters are validated
- Transaction failures are handled gracefully
- Loading states are managed automatically

## Dependencies

Make sure you have the following dependencies installed:

```json
{
  "@solana/web3.js": "^1.90.0",
  "@solana/spl-token": "^0.4.0",
  "@metaplex-foundation/mpl-token-metadata": "^3.2.0"
}
```

## Network Configuration

The contract functions work with any Solana network. For development, use:

- **Devnet**: `https://api.devnet.solana.com`
- **Testnet**: `https://api.testnet.solana.com`
- **Mainnet**: `https://api.mainnet-beta.solana.com`

## Security Notes

1. Always validate user inputs before calling contract functions
2. Use proper wallet integration for production applications
3. Consider implementing rate limiting for public-facing functions
4. Test thoroughly on devnet before deploying to mainnet
5. The frontend no longer requires private keys - all signing is done through the connected wallet 