import { useState, useCallback } from 'react';
import { Connection, Keypair, PublicKey } from '@solana/web3.js';
import {
  mintAccessNFT,
  verifyAccess,
  updateCampaignData,
  getCampaignInfo,
  checkUserAccess,
  getUserCampaigns,
  CampaignData,
  MintAccessNFTParams,
  VerifyAccessParams,
  UpdateCampaignDataParams,
  GetCampaignInfoParams,
} from '@/lib/contract';

export interface UseContractReturn {
  // State
  loading: boolean;
  error: string | null;
  
  // Functions
  mintNFT: (params: MintAccessNFTParams) => Promise<string | null>;
  verifyUserAccess: (params: VerifyAccessParams) => Promise<boolean>;
  updateCampaign: (params: UpdateCampaignDataParams) => Promise<string | null>;
  getCampaign: (params: GetCampaignInfoParams) => Promise<CampaignData | null>;
  checkAccess: (userPublicKey: PublicKey, campaignId: string) => Promise<boolean>;
  getUserCampaignsList: (userPublicKey: PublicKey) => Promise<CampaignData[]>;
  
  // Utilities
  clearError: () => void;
}

export function useContract(connection: Connection): UseContractReturn {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const mintNFT = useCallback(async (params: MintAccessNFTParams): Promise<string | null> => {
    setLoading(true);
    setError(null);
    
    try {
      const signature = await mintAccessNFT(connection, params);
      return signature;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to mint NFT';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }, [connection]);

  const verifyUserAccess = useCallback(async (params: VerifyAccessParams): Promise<boolean> => {
    setLoading(true);
    setError(null);
    
    try {
      const hasAccess = await verifyAccess(connection, params);
      return hasAccess;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to verify access';
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }, [connection]);

  const updateCampaign = useCallback(async (params: UpdateCampaignDataParams): Promise<string | null> => {
    setLoading(true);
    setError(null);
    
    try {
      const signature = await updateCampaignData(connection, params);
      return signature;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to update campaign';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }, [connection]);

  const getCampaign = useCallback(async (params: GetCampaignInfoParams): Promise<CampaignData | null> => {
    setLoading(true);
    setError(null);
    
    try {
      const campaignData = await getCampaignInfo(connection, params);
      return campaignData;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to get campaign info';
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  }, [connection]);

  const checkAccess = useCallback(async (userPublicKey: PublicKey, campaignId: string): Promise<boolean> => {
    setLoading(true);
    setError(null);
    
    try {
      const hasAccess = await checkUserAccess(connection, userPublicKey, campaignId);
      return hasAccess;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to check access';
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }, [connection]);

  const getUserCampaignsList = useCallback(async (userPublicKey: PublicKey): Promise<CampaignData[]> => {
    setLoading(true);
    setError(null);
    
    try {
      const campaigns = await getUserCampaigns(connection, userPublicKey);
      return campaigns;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to get user campaigns';
      setError(errorMessage);
      return [];
    } finally {
      setLoading(false);
    }
  }, [connection]);

  return {
    loading,
    error,
    mintNFT,
    verifyUserAccess,
    updateCampaign,
    getCampaign,
    checkAccess,
    getUserCampaignsList,
    clearError,
  };
} 