'use client';

import { useState } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { useConnection } from '@solana/wallet-adapter-react';
import { useContract } from '@/hooks/useContract';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Loader2, CheckCircle, XCircle, Wallet, Shield, Settings, Info } from 'lucide-react';

export function ContractExample() {
  const { publicKey, connected, signTransaction } = useWallet();
  const { connection } = useConnection();
  const { 
    loading, 
    error, 
    mintNFT, 
    verifyUserAccess, 
    getCampaign, 
    clearError 
  } = useContract(connection);

  // Form states
  const [campaignId, setCampaignId] = useState('');
  const [campaignName, setCampaignName] = useState('');
  const [campaignSymbol, setCampaignSymbol] = useState('');
  const [campaignUri, setCampaignUri] = useState('');
  const [agentCount, setAgentCount] = useState(1);

  // Results
  const [mintResult, setMintResult] = useState<string | null>(null);
  const [verifyResult, setVerifyResult] = useState<boolean | null>(null);
  const [campaignData, setCampaignData] = useState<any>(null);

  const handleMintNFT = async () => {
    if (!connected || !publicKey || !signTransaction) {
      alert('Please connect your wallet first');
      return;
    }

    clearError();
    setMintResult(null);

    try {
      const result = await mintNFT({
        campaignId,
        name: campaignName,
        symbol: campaignSymbol,
        uri: campaignUri,
        agentCount,
        payer: publicKey,
        mintAuthority: publicKey,
        signTransaction,
      });
      
      if (result) {
        setMintResult(result);
      }
    } catch (err) {
      console.error('Minting failed:', err);
    }
  };

  const handleVerifyAccess = async () => {
    if (!connected || !publicKey || !signTransaction) {
      alert('Please connect your wallet first');
      return;
    }

    clearError();
    setVerifyResult(null);

    try {
      const wallet = {
        publicKey,
        signTransaction,
        signAllTransactions: async (transactions: any[]) => {
          const signedTransactions = [];
          for (const transaction of transactions) {
            signedTransactions.push(await signTransaction(transaction));
          }
          return signedTransactions;
        },
      };
      
      const result = await verifyUserAccess(wallet, campaignId);
      setVerifyResult(result);
    } catch (err) {
      console.error('Verification failed:', err);
    }
  };

  const handleGetCampaign = async () => {
    if (!connected || !publicKey || !signTransaction) {
      alert('Please connect your wallet first');
      return;
    }

    clearError();
    setCampaignData(null);

    try {
      const wallet = {
        publicKey,
        signTransaction,
        signAllTransactions: async (transactions: any[]) => {
          const signedTransactions = [];
          for (const transaction of transactions) {
            signedTransactions.push(await signTransaction(transaction));
          }
          return signedTransactions;
        },
      };
      
      const result = await getCampaign(wallet, campaignId);
      setCampaignData(result);
    } catch (err) {
      console.error('Get campaign failed:', err);
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <Shield className="w-5 h-5" />
            <span>Access NFT Contract Example</span>
          </CardTitle>
          <CardDescription>
            Test the Access NFT contract functions. Make sure your wallet is connected.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Wallet Status */}
          <div className="flex items-center space-x-2">
            <Wallet className="w-4 h-4" />
            <span className="text-sm">
              Wallet Status: {connected ? (
                <Badge variant="default" className="ml-2">Connected</Badge>
              ) : (
                <Badge variant="secondary" className="ml-2">Not Connected</Badge>
              )}
            </span>
          </div>

          {/* Form Fields */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="campaignId">Campaign ID</Label>
              <Input
                id="campaignId"
                value={campaignId}
                onChange={(e) => setCampaignId(e.target.value)}
                placeholder="Enter campaign ID"
              />
            </div>
            <div>
              <Label htmlFor="campaignName">NFT Name</Label>
              <Input
                id="campaignName"
                value={campaignName}
                onChange={(e) => setCampaignName(e.target.value)}
                placeholder="Enter NFT name"
              />
            </div>
            <div>
              <Label htmlFor="campaignSymbol">NFT Symbol</Label>
              <Input
                id="campaignSymbol"
                value={campaignSymbol}
                onChange={(e) => setCampaignSymbol(e.target.value)}
                placeholder="Enter NFT symbol"
              />
            </div>
            <div>
              <Label htmlFor="campaignUri">Metadata URI</Label>
              <Input
                id="campaignUri"
                value={campaignUri}
                onChange={(e) => setCampaignUri(e.target.value)}
                placeholder="Enter metadata URI"
              />
            </div>
            <div>
              <Label htmlFor="agentCount">Agent Count</Label>
              <Input
                id="agentCount"
                type="number"
                value={agentCount}
                onChange={(e) => setAgentCount(parseInt(e.target.value) || 1)}
                placeholder="Enter agent count"
              />
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex space-x-4">
            <Button 
              onClick={handleMintNFT} 
              disabled={!connected || loading}
              className="flex items-center space-x-2"
            >
              {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
              <span>Mint NFT</span>
            </Button>
            
            <Button 
              onClick={handleVerifyAccess} 
              disabled={!connected || loading}
              variant="outline"
              className="flex items-center space-x-2"
            >
              {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <XCircle className="w-4 h-4" />}
              <span>Verify Access</span>
            </Button>
            
            <Button 
              onClick={handleGetCampaign} 
              disabled={!connected || loading}
              variant="outline"
              className="flex items-center space-x-2"
            >
              {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Info className="w-4 h-4" />}
              <span>Get Campaign</span>
            </Button>
          </div>

          {/* Error Display */}
          {error && (
            <Alert>
              <XCircle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          {/* Results Display */}
          {mintResult && (
            <Alert>
              <CheckCircle className="h-4 w-4" />
              <AlertDescription>
                NFT minted successfully! Transaction: {mintResult.slice(0, 8)}...{mintResult.slice(-8)}
              </AlertDescription>
            </Alert>
          )}

          {verifyResult !== null && (
            <Alert>
              {verifyResult ? <CheckCircle className="h-4 w-4" /> : <XCircle className="h-4 w-4" />}
              <AlertDescription>
                {verifyResult ? 'Access verified successfully!' : 'Access denied.'}
              </AlertDescription>
            </Alert>
          )}

          {campaignData && (
            <Card>
              <CardHeader>
                <CardTitle>Campaign Information</CardTitle>
              </CardHeader>
              <CardContent>
                <pre className="text-sm bg-gray-100 p-4 rounded overflow-auto">
                  {JSON.stringify(campaignData, null, 2)}
                </pre>
              </CardContent>
            </Card>
          )}
        </CardContent>
      </Card>
    </div>
  );
} 