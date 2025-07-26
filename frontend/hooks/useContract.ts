import { useState } from 'react';
import { Connection } from '@solana/web3.js';
import { AnchorWallet } from '@solana/wallet-adapter-react';
import { getProgram, mintAccessNFT, verifyAccess, getCampaignInfo } from '@/lib/contract';

interface MintParams {
  campaignId: string;
  name: string;
  symbol: string;
  uri: string;
  agentCount: number;
  payer: any;
  mintAuthority: any;
  signTransaction: any;
}

export const useContract = (connection: Connection) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = () => setError(null);

  const mintNFT = async (params: MintParams) => {
    if (!connection) {
      setError('No connection available');
      return null;
    }

    setLoading(true);
    setError(null);

    try {
      // Create a wallet object that matches AnchorWallet interface
      const wallet: AnchorWallet = {
        publicKey: params.payer,
        signTransaction: params.signTransaction,
        signAllTransactions: async (transactions) => {
          const signedTransactions = [];
          for (const transaction of transactions) {
            signedTransactions.push(await params.signTransaction(transaction));
          }
          return signedTransactions;
        },
      };

      const program = getProgram(connection, wallet);
      
      const signature = await mintAccessNFT(
        program,
        wallet,
        params.campaignId,
        params.name,
        params.symbol,
        params.uri,
        params.agentCount
      );

      return signature;
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to mint NFT';
      setError(errorMessage);
      console.error('Minting error:', err);
      return null;
    } finally {
      setLoading(false);
    }
  };

  const verifyUserAccess = async (wallet: AnchorWallet, campaignId: string) => {
    if (!connection) {
      setError('No connection available');
      return false;
    }

    setLoading(true);
    setError(null);

    try {
      const program = getProgram(connection, wallet);
      const hasAccess = await verifyAccess(program, wallet, campaignId);
      return hasAccess;
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to verify access';
      setError(errorMessage);
      console.error('Access verification error:', err);
      return false;
    } finally {
      setLoading(false);
    }
  };

  const getCampaign = async (wallet: AnchorWallet, campaignId: string) => {
    if (!connection) {
      setError('No connection available');
      return null;
    }

    setLoading(true);
    setError(null);

    try {
      const program = getProgram(connection, wallet);
      const campaignData = await getCampaignInfo(program, campaignId);
      return campaignData;
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to get campaign info';
      setError(errorMessage);
      console.error('Get campaign error:', err);
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    mintNFT,
    verifyUserAccess,
    getCampaign,
    loading,
    error,
    clearError,
  };
}; 