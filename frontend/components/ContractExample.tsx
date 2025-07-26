'use client';

import { useState } from 'react';
import { Connection, Keypair, PublicKey } from '@solana/web3.js';
import { useContract } from '@/hooks/useContract';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Loader2, CheckCircle, XCircle, Wallet, Shield, Settings, Info } from 'lucide-react';

export function ContractExample() {
  const [connection] = useState(() => new Connection('https://api.devnet.solana.com'));
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

  // Form states
  const [campaignId, setCampaignId] = useState('');
  const [campaignName, setCampaignName] = useState('');
  const [campaignSymbol, setCampaignSymbol] = useState('');
  const [campaignUri, setCampaignUri] = useState('');
  const [agentCount, setAgentCount] = useState(1);
  const [userPublicKey, setUserPublicKey] = useState('');
  const [newUri, setNewUri] = useState('');
  const [newAgentCount, setNewAgentCount] = useState(1);

  // Results
  const [mintResult, setMintResult] = useState<string | null>(null);
  const [verifyResult, setVerifyResult] = useState<boolean | null>(null);
  const [campaignData, setCampaignData] = useState<any>(null);
  const [accessResult, setAccessResult] = useState<boolean | null>(null);

  const handleMintNFT = async () => {
    const payer = Keypair.generate();
    const mintAuthority = Keypair.generate();
    
    const result = await mintNFT({
      campaignId,
      name: campaignName,
      symbol: campaignSymbol,
      uri: campaignUri,
      agentCount,
      payer,
      mintAuthority,
    });
    
    setMintResult(result);
  };

  const handleVerifyAccess = async () => {
    const user = Keypair.generate();
    const result = await verifyUserAccess({
      campaignId,
      user,
    });
    
    setVerifyResult(result);
  };

  const handleGetCampaign = async () => {
    const result = await getCampaign({ campaignId });
    setCampaignData(result);
  };

  const handleCheckAccess = async () => {
    if (!userPublicKey) return;
    
    const result = await checkAccess(new PublicKey(userPublicKey), campaignId);
    setAccessResult(result);
  };

  const handleUpdateCampaign = async () => {
    const authority = Keypair.generate();
    const result = await updateCampaign({
      campaignId,
      authority,
      newUri: newUri || undefined,
      newAgentCount: newAgentCount || undefined,
    });
    
    if (result) {
      setMintResult(result);
    }
  };

  return (
    <div className="container mx-auto p-6 space-y-6">
      <div className="text-center space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">Solana Contract Functions</h1>
        <p className="text-muted-foreground">
          Example usage of the access NFT contract functions
        </p>
      </div>

      {error && (
        <Alert variant="destructive">
          <XCircle className="h-4 w-4" />
          <AlertDescription>
            {error}
            <Button variant="link" onClick={clearError} className="p-0 h-auto">
              Dismiss
            </Button>
          </AlertDescription>
        </Alert>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Mint NFT */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Wallet className="h-5 w-5" />
              Mint Access NFT
            </CardTitle>
            <CardDescription>
              Create a new access NFT for a campaign
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="campaignId">Campaign ID</Label>
              <Input
                id="campaignId"
                value={campaignId}
                onChange={(e) => setCampaignId(e.target.value)}
                placeholder="Enter campaign ID"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="name">NFT Name</Label>
              <Input
                id="name"
                value={campaignName}
                onChange={(e) => setCampaignName(e.target.value)}
                placeholder="Access NFT"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="symbol">Symbol</Label>
              <Input
                id="symbol"
                value={campaignSymbol}
                onChange={(e) => setCampaignSymbol(e.target.value)}
                placeholder="ACCESS"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="uri">Metadata URI</Label>
              <Input
                id="uri"
                value={campaignUri}
                onChange={(e) => setCampaignUri(e.target.value)}
                placeholder="https://example.com/metadata.json"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="agentCount">Agent Count</Label>
              <Input
                id="agentCount"
                type="number"
                value={agentCount}
                onChange={(e) => setAgentCount(parseInt(e.target.value))}
                min="1"
              />
            </div>
            <Button 
              onClick={handleMintNFT} 
              disabled={loading || !campaignId || !campaignName || !campaignSymbol || !campaignUri}
              className="w-full"
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Mint NFT
            </Button>
            {mintResult && (
              <div className="p-3 bg-green-50 border border-green-200 rounded-md">
                <p className="text-sm text-green-800">
                  <CheckCircle className="inline h-4 w-4 mr-1" />
                  Transaction successful! Signature: {mintResult.slice(0, 8)}...
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Verify Access */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Verify Access
            </CardTitle>
            <CardDescription>
              Verify if a user has access to a campaign
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="verifyCampaignId">Campaign ID</Label>
              <Input
                id="verifyCampaignId"
                value={campaignId}
                onChange={(e) => setCampaignId(e.target.value)}
                placeholder="Enter campaign ID"
              />
            </div>
            <Button 
              onClick={handleVerifyAccess} 
              disabled={loading || !campaignId}
              className="w-full"
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Verify Access
            </Button>
            {verifyResult !== null && (
              <div className={`p-3 border rounded-md ${verifyResult ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
                <p className={`text-sm ${verifyResult ? 'text-green-800' : 'text-red-800'}`}>
                  {verifyResult ? (
                    <>
                      <CheckCircle className="inline h-4 w-4 mr-1" />
                      Access verified successfully!
                    </>
                  ) : (
                    <>
                      <XCircle className="inline h-4 w-4 mr-1" />
                      Access denied
                    </>
                  )}
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Get Campaign Info */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Info className="h-5 w-5" />
              Get Campaign Info
            </CardTitle>
            <CardDescription>
              Retrieve campaign information
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="infoCampaignId">Campaign ID</Label>
              <Input
                id="infoCampaignId"
                value={campaignId}
                onChange={(e) => setCampaignId(e.target.value)}
                placeholder="Enter campaign ID"
              />
            </div>
            <Button 
              onClick={handleGetCampaign} 
              disabled={loading || !campaignId}
              className="w-full"
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Get Campaign Info
            </Button>
            {campaignData && (
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-sm font-medium">ID:</span>
                  <Badge variant="secondary">{campaignData.id}</Badge>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm font-medium">Agent Count:</span>
                  <Badge variant="outline">{campaignData.agentCount}</Badge>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm font-medium">Created:</span>
                  <Badge variant="outline">
                    {new Date(campaignData.createdAt * 1000).toLocaleDateString()}
                  </Badge>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Check User Access */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Shield className="h-5 w-5" />
              Check User Access
            </CardTitle>
            <CardDescription>
              Check if a specific user has access
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="userPublicKey">User Public Key</Label>
              <Input
                id="userPublicKey"
                value={userPublicKey}
                onChange={(e) => setUserPublicKey(e.target.value)}
                placeholder="Enter user public key"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="accessCampaignId">Campaign ID</Label>
              <Input
                id="accessCampaignId"
                value={campaignId}
                onChange={(e) => setCampaignId(e.target.value)}
                placeholder="Enter campaign ID"
              />
            </div>
            <Button 
              onClick={handleCheckAccess} 
              disabled={loading || !userPublicKey || !campaignId}
              className="w-full"
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Check Access
            </Button>
            {accessResult !== null && (
              <div className={`p-3 border rounded-md ${accessResult ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
                <p className={`text-sm ${accessResult ? 'text-green-800' : 'text-red-800'}`}>
                  {accessResult ? (
                    <>
                      <CheckCircle className="inline h-4 w-4 mr-1" />
                      User has access
                    </>
                  ) : (
                    <>
                      <XCircle className="inline h-4 w-4 mr-1" />
                      User does not have access
                    </>
                  )}
                </p>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Update Campaign */}
        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Settings className="h-5 w-5" />
              Update Campaign Data
            </CardTitle>
            <CardDescription>
              Update campaign metadata (only by original mint authority)
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="updateCampaignId">Campaign ID</Label>
                <Input
                  id="updateCampaignId"
                  value={campaignId}
                  onChange={(e) => setCampaignId(e.target.value)}
                  placeholder="Enter campaign ID"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="newUri">New URI (optional)</Label>
                <Input
                  id="newUri"
                  value={newUri}
                  onChange={(e) => setNewUri(e.target.value)}
                  placeholder="https://example.com/new-metadata.json"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="newAgentCount">New Agent Count (optional)</Label>
                <Input
                  id="newAgentCount"
                  type="number"
                  value={newAgentCount}
                  onChange={(e) => setNewAgentCount(parseInt(e.target.value))}
                  min="1"
                />
              </div>
            </div>
            <Button 
              onClick={handleUpdateCampaign} 
              disabled={loading || !campaignId}
              className="w-full"
            >
              {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
              Update Campaign
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
} 