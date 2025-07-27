'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useWallet } from '@solana/wallet-adapter-react';
import { useConnection } from '@solana/wallet-adapter-react';
import { useContract } from '@/hooks/useContract';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Slider } from '@/components/ui/slider';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { 
  Wallet, 
  Database, 
  Server, 
  Zap,
  Globe,
  Cpu,
  Shield,
  Settings,
  Play,
  BarChart3,
  AlertTriangle,
  CheckCircle,
  DollarSign,
  Key,
  Users,
  Target,
  Activity,
  TrendingUp,
  AlertCircle,
  Info,
  Sparkles,
  Loader2
} from 'lucide-react';

interface CampaignForm {
  // Campaign Configuration
  name: string;
  id: string;
  platforms: string[];
  keywords: string[];
  hashtags: string[];
  spamThreshold: number;
  sentimentThreshold: number;
  
  // Resource Allocation
  crawlerAgents: string[]; // Automatically generated based on platforms
  consensusAgentCount: number; // Odd number of consensus agents
  budget: number;
  
  // Wallet Essentials
  walletConnected: boolean;
  walletAddress: string;
  solBalance: number;
  
  // JuliaOS Access
  juliaOSAccount: string;
  apiKey: string;
}

export default function CampaignPage() {
  const { publicKey, connected, signTransaction } = useWallet();
  const { connection } = useConnection();
  const { mintNFT, loading: contractLoading, error: contractError, clearError } = useContract(connection);
  
  const [formData, setFormData] = useState<CampaignForm>({
    name: '',
    id: '',
    platforms: [],
    keywords: [],
    hashtags: [],
    spamThreshold: 15,
    sentimentThreshold: 30,
    crawlerAgents: [],
    consensusAgentCount: 3, // Start with 3 consensus agents (odd number)
    budget: 100,
    walletConnected: false,
    walletAddress: '',
    solBalance: 0,
    juliaOSAccount: '',
    apiKey: ''
  });

  const [currentStep, setCurrentStep] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isLoadingBalance, setIsLoadingBalance] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [nftSignature, setNftSignature] = useState<string | null>(null);

  const platforms = [
    { id: 'twitter', name: 'Twitter', icon: '🐦', agent: 'twitter.jl' },
    { id: 'reddit', name: 'Reddit', icon: '🤖', agent: 'reddit.jl' },
    { id: 'discord', name: 'Discord', icon: '💬', agent: 'discord.jl' },
    { id: 'telegram', name: 'Telegram', icon: '📱', agent: 'telegram.jl' },
    { id: 'instagram', name: 'Instagram', icon: '📸', agent: 'instagram.jl' },
    { id: 'youtube', name: 'YouTube', icon: '📺', agent: 'youtube.jl' }
  ];

  // Function to generate crawler agents based on selected platforms
  const generateCrawlerAgents = (selectedPlatforms: string[]) => {
    return selectedPlatforms.map(platformId => {
      const platform = platforms.find(p => p.id === platformId);
      return platform?.agent || `${platformId}.jl`;
    });
  };

  // Update wallet connection status when wallet connects/disconnects
  useEffect(() => {
    if (connected && publicKey) {
      setFormData(prev => ({
        ...prev,
        walletConnected: true,
        walletAddress: publicKey.toString()
      }));
      fetchWalletBalance();
    } else {
      setFormData(prev => ({
        ...prev,
        walletConnected: false,
        walletAddress: '',
        solBalance: 0
      }));
    }
  }, [connected, publicKey]);

  // Update crawler agents when platforms change
  useEffect(() => {
    const generatedAgents = generateCrawlerAgents(formData.platforms);
    setFormData(prev => ({
      ...prev,
      crawlerAgents: generatedAgents
    }));
  }, [formData.platforms]);

  const fetchWalletBalance = async () => {
    if (!connection || !publicKey) return;
    
    setIsLoadingBalance(true);
    try {
      const balance = await connection.getBalance(publicKey);
      const solBalance = balance / 1e9; // Convert lamports to SOL
      setFormData(prev => ({
        ...prev,
        solBalance: solBalance
      }));
    } catch (error) {
      console.error('Error fetching wallet balance:', error);
    } finally {
      setIsLoadingBalance(false);
    }
  };

  const handlePlatformToggle = (platformId: string) => {
    setFormData(prev => ({
      ...prev,
      platforms: prev.platforms.includes(platformId)
        ? prev.platforms.filter(p => p !== platformId)
        : [...prev.platforms, platformId]
    }));
  };

  const handleKeywordAdd = (keyword: string) => {
    if (keyword && !formData.keywords.includes(keyword)) {
      setFormData(prev => ({
        ...prev,
        keywords: [...prev.keywords, keyword]
      }));
    }
  };

  const handleHashtagAdd = (hashtag: string) => {
    if (hashtag && !formData.hashtags.includes(hashtag)) {
      setFormData(prev => ({
        ...prev,
        hashtags: [...prev.hashtags, hashtag]
      }));
    }
  };

  const connectWallet = () => {
    // The wallet connection is handled by the wallet adapter
    // This function is now just for UI feedback
    if (!connected) {
      // Trigger wallet modal
      // The actual connection is handled by the wallet adapter
    }
  };

  const handleSubmit = async () => {
    setSuccessMessage(null);
    setErrorMessage(null);
    setNftSignature(null);
    clearError();

    if (!formData.walletConnected) {
      setErrorMessage('Please connect your wallet first');
      return;
    }

    if (!formData.name || !formData.id) {
      setErrorMessage('Please fill in campaign name and ID');
      return;
    }

    if (formData.platforms.length === 0) {
      setErrorMessage('Please select at least one platform to monitor');
      return;
    }

    if (formData.keywords.length === 0 && formData.hashtags.length === 0) {
      setErrorMessage('Please add at least one keyword or hashtag to monitor');
      return;
    }

    setIsSubmitting(true);
    
    try {
      // Step 1: Create campaign
      const campaignData = {
        name: formData.name,
        hashtag: formData.id,
        description: `Campaign monitoring ${formData.platforms.join(', ')} for keywords: ${formData.keywords.join(', ')} and hashtags: ${formData.hashtags.join(', ')}`,
        startDate: new Date().toISOString(),
        metadata: {
          platforms: formData.platforms,
          keywords: formData.keywords,
          hashtags: formData.hashtags,
          spamThreshold: formData.spamThreshold,
          sentimentThreshold: formData.sentimentThreshold,
          crawlerAgents: formData.crawlerAgents,
          consensusAgentCount: formData.consensusAgentCount,
          fixedAnalyzers: ['sentiment_analyzer', 'trend_analyzer'],
          budget: formData.budget,
          walletAddress: formData.walletAddress,
          juliaOSAccount: formData.juliaOSAccount,
        }
      };

      // Log campaign data before submission
      console.log('=== FRONTEND CAMPAIGN SUBMISSION LOG ===');
      console.log('Form Data:', formData);
      console.log('Campaign Data to Submit:', campaignData);
      console.log('Generated Crawler Agents:', formData.crawlerAgents);
      console.log('Total Agents:', formData.crawlerAgents.length + formData.consensusAgentCount + 2);
      console.log('Selected Platforms:', formData.platforms);
      console.log('=== END FRONTEND LOG ===');

      const response = await fetch('/api/campaigns', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(campaignData),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }

      const createdCampaign = await response.json();
      
      // Log campaign creation response
      console.log('=== CAMPAIGN CREATION RESPONSE LOG ===');
      console.log('Created Campaign:', createdCampaign);
      console.log('Campaign ID:', createdCampaign.id);
      console.log('Campaign Name:', createdCampaign.name);
      console.log('Campaign Metadata:', createdCampaign.metadata);
      console.log('Agent Details:', createdCampaign.metadata?.agentDetails);
      console.log('Agent Creation Results:', createdCampaign.agentCreation);
      console.log('=== END RESPONSE LOG ===');
      
      // Step 2: Mint NFT for campaign access
      if (connected && publicKey && signTransaction) {
        const nftParams = {
          campaignId: createdCampaign.id,
          name: `${formData.name} Access Token`,
          symbol: 'TGAP',
          uri: `https://ipfs.io/ipfs/Qm${Date.now()}`,
          agentCount: createdCampaign.agentCreation?.createdAgents || formData.crawlerAgents.length,
          payer: publicKey,
          mintAuthority: publicKey,
          signTransaction
        };

        // Log NFT minting parameters
        console.log('=== NFT MINTING LOG ===');
        console.log('NFT Parameters:', nftParams);
        console.log('Agent Count for NFT:', createdCampaign.agentCreation?.createdAgents || formData.crawlerAgents.length);
        console.log('Created Agents:', createdCampaign.agentCreation?.agentDetails || []);
        console.log('=== END NFT LOG ===');

        const signature = await mintNFT(nftParams);
        
        if (signature) {
          setNftSignature(signature);
          const agentCount = createdCampaign.agentCreation?.createdAgents || 0;
          const errorCount = createdCampaign.agentCreation?.errors || 0;
          const successMsg = `Campaign "${createdCampaign.name}" created successfully! Campaign ID: ${createdCampaign.id}. Created ${agentCount} agents. NFT minted with signature: ${signature.slice(0, 8)}...${signature.slice(-8)}`;
          if (errorCount > 0) {
            setSuccessMessage(`${successMsg} Note: ${errorCount} agents failed to create.`);
          } else {
            setSuccessMessage(successMsg);
          }
          
          // Log successful campaign creation with NFT
          console.log('=== SUCCESS LOG ===');
          console.log('Campaign created successfully with NFT');
          console.log('Campaign ID:', createdCampaign.id);
          console.log('NFT Signature:', signature);
          console.log('Total Agents Created:', agentCount);
          console.log('Agent Errors:', errorCount);
          console.log('=== END SUCCESS LOG ===');
        } else {
          const agentCount = createdCampaign.agentCreation?.createdAgents || 0;
          const errorCount = createdCampaign.agentCreation?.errors || 0;
          const partialMsg = `Campaign "${createdCampaign.name}" created successfully! Campaign ID: ${createdCampaign.id}. Created ${agentCount} agents. NFT minting failed.`;
          if (errorCount > 0) {
            setSuccessMessage(`${partialMsg} Note: ${errorCount} agents failed to create.`);
          } else {
            setSuccessMessage(partialMsg);
          }
          
          // Log campaign creation with NFT failure
          console.log('=== PARTIAL SUCCESS LOG ===');
          console.log('Campaign created but NFT minting failed');
          console.log('Campaign ID:', createdCampaign.id);
          console.log('Total Agents Created:', agentCount);
          console.log('Agent Errors:', errorCount);
          console.log('=== END PARTIAL SUCCESS LOG ===');
        }
      } else {
        const agentCount = createdCampaign.agentCreation?.createdAgents || 0;
        const errorCount = createdCampaign.agentCreation?.errors || 0;
        const campaignMsg = `Campaign "${createdCampaign.name}" created successfully! Campaign ID: ${createdCampaign.id}. Created ${agentCount} agents. Please connect wallet to mint access NFT.`;
        if (errorCount > 0) {
          setSuccessMessage(`${campaignMsg} Note: ${errorCount} agents failed to create.`);
        } else {
          setSuccessMessage(campaignMsg);
        }
        
        // Log campaign creation without wallet
        console.log('=== CAMPAIGN ONLY LOG ===');
        console.log('Campaign created without wallet connection');
        console.log('Campaign ID:', createdCampaign.id);
        console.log('Wallet Connected:', connected);
        console.log('Total Agents Created:', agentCount);
        console.log('Agent Errors:', errorCount);
        console.log('=== END CAMPAIGN ONLY LOG ===');
      }
      
      // Reset form
      setFormData({
        name: '',
        id: '',
        platforms: [],
        keywords: [],
        hashtags: [],
        spamThreshold: 15,
        sentimentThreshold: 30,
        crawlerAgents: [],
        consensusAgentCount: 3,
        budget: 100,
        walletConnected: formData.walletConnected,
        walletAddress: formData.walletAddress,
        solBalance: formData.solBalance,
        juliaOSAccount: '',
        apiKey: ''
      });
      
      setCurrentStep(0);
      
    } catch (error) {
      console.error('Error creating campaign:', error);
      setErrorMessage(`Failed to create campaign: ${error instanceof Error ? error.message : 'Unknown error'}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  const clearMessages = () => {
    setSuccessMessage(null);
    setErrorMessage(null);
  };

  const handleNextStep = () => {
    clearMessages();
    setCurrentStep(prev => prev + 1);
  };

  const handlePreviousStep = () => {
    clearMessages();
    setCurrentStep(prev => Math.max(0, prev - 1));
  };

  const steps = [
    { id: 'config', title: 'Campaign Configuration', icon: Settings },
    { id: 'resources', title: 'Resource Allocation', icon: Cpu },
    { id: 'wallet', title: 'Wallet Setup', icon: Wallet },
    { id: 'juliaos', title: 'JuliaOS Access', icon: Key }
  ];

  const renderStep = () => {
    switch (currentStep) {
      case 0:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="space-y-6"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <Label htmlFor="name">Campaign Name</Label>
                <Input
                  id="name"
                  placeholder="e.g., Medterra Summer Launch"
                  value={formData.name}
                  onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                />
              </div>
              
              <div className="space-y-4">
                <Label htmlFor="id">Campaign ID</Label>
                <Input
                  id="id"
                  placeholder="e.g., medterra_summer_launch"
                  value={formData.id}
                  onChange={(e) => setFormData(prev => ({ ...prev, id: e.target.value }))}
                />
              </div>
            </div>

            <div className="space-y-4">
              <Label>Platforms to Monitor</Label>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {platforms.map((platform) => (
                  <motion.button
                    key={platform.id}
                    type="button"
                    className={`p-3 rounded-lg border-2 transition-all duration-200 flex items-center space-x-2 ${
                      formData.platforms.includes(platform.id)
                        ? 'border-purple-500 bg-purple-500/20'
                        : 'border-gray-600 bg-gray-800/50 hover:border-gray-500'
                    }`}
                    onClick={() => handlePlatformToggle(platform.id)}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    <span className="text-lg">{platform.icon}</span>
                    <span className="text-sm font-medium">{platform.name}</span>
                  </motion.button>
                ))}
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <Label>Target Keywords</Label>
                <div className="space-y-2">
                  <div className="flex space-x-2">
                    <Input
                      placeholder="Add keyword..."
                      onKeyPress={(e) => {
                        if (e.key === 'Enter') {
                          handleKeywordAdd(e.currentTarget.value);
                          e.currentTarget.value = '';
                        }
                      }}
                    />
                    <Button
                      type="button"
                      variant="outline"
                      onClick={(e) => {
                        const input = e.currentTarget.previousElementSibling as HTMLInputElement;
                        handleKeywordAdd(input.value);
                        input.value = '';
                      }}
                    >
                      Add
                    </Button>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {formData.keywords.map((keyword, index) => (
                      <Badge key={index} variant="secondary" className="bg-blue-500/20 text-blue-400">
                        {keyword}
                      </Badge>
                    ))}
                  </div>
                </div>
              </div>

              <div className="space-y-4">
                <Label>Target Hashtags</Label>
                <div className="space-y-2">
                  <div className="flex space-x-2">
                    <Input
                      placeholder="Add hashtag..."
                      onKeyPress={(e) => {
                        if (e.key === 'Enter') {
                          handleHashtagAdd(e.currentTarget.value);
                          e.currentTarget.value = '';
                        }
                      }}
                    />
                    <Button
                      type="button"
                      variant="outline"
                      onClick={(e) => {
                        const input = e.currentTarget.previousElementSibling as HTMLInputElement;
                        handleHashtagAdd(input.value);
                        input.value = '';
                      }}
                    >
                      Add
                    </Button>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {formData.hashtags.map((hashtag, index) => (
                      <Badge key={index} variant="secondary" className="bg-green-500/20 text-green-400">
                        {hashtag}
                      </Badge>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <Label>Spam Alert Threshold: {formData.spamThreshold}%</Label>
                <Slider
                  value={[formData.spamThreshold]}
                  onValueChange={(value) => setFormData(prev => ({ ...prev, spamThreshold: value[0] }))}
                  max={50}
                  min={5}
                  step={5}
                  className="w-full"
                />
              </div>

              <div className="space-y-4">
                <Label>Sentiment Drop Threshold: {formData.sentimentThreshold}%</Label>
                <Slider
                  value={[formData.sentimentThreshold]}
                  onValueChange={(value) => setFormData(prev => ({ ...prev, sentimentThreshold: value[0] }))}
                  max={50}
                  min={10}
                  step={5}
                  className="w-full"
                />
              </div>
            </div>
          </motion.div>
        );

      case 1:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="space-y-6"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card className="glassmorphism border-blue-500/20">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <Cpu className="w-5 h-5 text-blue-400" />
                    <span>Agent Deployment</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-4">
                    <Label>Crawler Agents: {formData.crawlerAgents.length}</Label>
                    <div className="space-y-2">
                      <p className="text-xs text-gray-400">Automatically generated based on selected platforms</p>
                      {formData.crawlerAgents.length > 0 ? (
                        <div className="space-y-2">
                          <div className="flex flex-wrap gap-2">
                            {formData.crawlerAgents.map((agent, index) => (
                              <Badge key={index} variant="secondary" className="bg-blue-500/20 text-blue-400">
                                {agent}
                              </Badge>
                            ))}
                          </div>
                          <p className="text-xs text-gray-400">
                            {formData.crawlerAgents.length} crawler agent{formData.crawlerAgents.length !== 1 ? 's' : ''} will be deployed
                          </p>
                        </div>
                      ) : (
                        <p className="text-xs text-orange-400">No platforms selected - no crawler agents will be deployed</p>
                      )}
                    </div>
                  </div>

                  <div className="space-y-4">
                    <Label>Analyzer Agents: {formData.consensusAgentCount}</Label>
                    <Slider
                      value={[formData.consensusAgentCount]}
                      onValueChange={(value) => setFormData(prev => ({ ...prev, consensusAgentCount: value[0] }))}
                      max={5}
                      min={1}
                      step={1}
                      className="w-full"
                    />
                    <p className="text-xs text-gray-400">Sentiment and content analysis agents</p>
                  </div>
                </CardContent>
              </Card>

              <Card className="glassmorphism border-green-500/20">
                <CardHeader>
                  <CardTitle className="flex items-center space-x-2">
                    <DollarSign className="w-5 h-5 text-green-400" />
                    <span>Budget Allocation</span>
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-4">
                    <Label>Monthly Budget: ${formData.budget}</Label>
                    <Slider
                      value={[formData.budget]}
                      onValueChange={(value) => setFormData(prev => ({ ...prev, budget: value[0] }))}
                      max={1000}
                      min={50}
                      step={50}
                      className="w-full"
                    />
                    <p className="text-xs text-gray-400">Covers gas fees and LLM costs</p>
                  </div>

                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-gray-400">Gas Fees:</span>
                      <span className="text-blue-400">~${formData.budget * 0.3}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-400">LLM Costs:</span>
                      <span className="text-green-400">~${formData.budget * 0.7}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-400">Total Agents:</span>
                      <span className="text-white">{formData.crawlerAgents.length + formData.consensusAgentCount + 2}</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </motion.div>
        );

      case 2:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="space-y-6"
          >
            <Card className="glassmorphism border-purple-500/20">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <Wallet className="w-5 h-5 text-purple-400" />
                  <span>Wallet Essentials</span>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                {!formData.walletConnected ? (
                  <div className="text-center space-y-4">
                    <div className="w-16 h-16 mx-auto bg-purple-500/20 rounded-full flex items-center justify-center">
                      <Wallet className="w-8 h-8 text-purple-400" />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold mb-2">Connect Your Wallet</h3>
                      <p className="text-gray-400 mb-4">
                        Connect your Solana wallet to mint campaign NFTs and manage operations
                      </p>
                    </div>
                    <Button onClick={connectWallet} className="bg-gradient-to-r from-purple-500 to-blue-500">
                      <Wallet className="w-4 h-4 mr-2" />
                      Connect Wallet
                    </Button>
                  </div>
                ) : (
                  <div className="space-y-4">
                    <div className="flex items-center space-x-2 text-green-400">
                      <CheckCircle className="w-5 h-5" />
                      <span className="font-medium">Wallet Connected</span>
                    </div>
                    
                    <div className="space-y-3">
                      <div className="flex justify-between items-center p-3 bg-gray-800/50 rounded-lg">
                        <span className="text-gray-400">Address:</span>
                        <span className="text-sm font-mono text-white">
                          {formData.walletAddress.slice(0, 8)}...{formData.walletAddress.slice(-8)}
                        </span>
                      </div>
                      
                      <div className="flex justify-between items-center p-3 bg-gray-800/50 rounded-lg">
                        <span className="text-gray-400">SOL Balance:</span>
                        <span className="text-green-400 font-medium">
                          {isLoadingBalance ? (
                            <span className="flex items-center space-x-2">
                              <div className="w-4 h-4 border-2 border-green-400 border-t-transparent rounded-full animate-spin"></div>
                              <span>Loading...</span>
                            </span>
                          ) : (
                            `${formData.solBalance.toFixed(4)} SOL`
                          )}
                        </span>
                      </div>
                    </div>

                    <div className="space-y-3">
                      <h4 className="font-semibold text-white">Required for Campaign:</h4>
                      <div className="space-y-2">
                        <div className="flex items-center justify-between p-2 bg-blue-500/10 rounded">
                          <span className="text-sm">NFT Minting Cost:</span>
                          <span className="text-blue-400">~0.0018 SOL</span>
                        </div>
                        <div className="flex items-center justify-between p-2 bg-green-500/10 rounded">
                          <span className="text-sm">Available Balance:</span>
                          <span className="text-green-400">{formData.solBalance.toFixed(4)} SOL</span>
                        </div>
                        {formData.solBalance < 0.002 && (
                          <div className="flex items-center justify-between p-2 bg-red-500/10 rounded">
                            <span className="text-sm text-red-400">Insufficient Balance</span>
                            <span className="text-red-400">Need at least 0.002 SOL</span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </motion.div>
        );

      case 3:
        return (
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="space-y-6"
          >
            <Card className="glassmorphism border-orange-500/20">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <Key className="w-5 h-5 text-orange-400" />
                  <span>JuliaOS Access</span>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-4">
                    <Label htmlFor="juliaOSAccount">JuliaOS Account</Label>
                    <Input
                      id="juliaOSAccount"
                      placeholder="your-account@juliaos.com"
                      value={formData.juliaOSAccount}
                      onChange={(e) => setFormData(prev => ({ ...prev, juliaOSAccount: e.target.value }))}
                    />
                  </div>
                  
                  <div className="space-y-4">
                    <Label htmlFor="apiKey">API Key</Label>
                    <Input
                      id="apiKey"
                      type="password"
                      placeholder="Enter your JuliaOS API key"
                      value={formData.apiKey}
                      onChange={(e) => setFormData(prev => ({ ...prev, apiKey: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="space-y-4">
                  <h4 className="font-semibold text-white">Access Requirements:</h4>
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2 text-sm">
                      <CheckCircle className="w-4 h-4 text-green-400" />
                      <span className="text-gray-300">Account on JuliaOS platform</span>
                    </div>
                    <div className="flex items-center space-x-2 text-sm">
                      <CheckCircle className="w-4 h-4 text-green-400" />
                      <span className="text-gray-300">API keys for agent deployment</span>
                    </div>
                    <div className="flex items-center space-x-2 text-sm">
                      <CheckCircle className="w-4 h-4 text-green-400" />
                      <span className="text-gray-300">Access to decentralized agent network</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        );

      default:
        return null;
    }
  };

  const isStepValid = (step: number) => {
    switch (step) {
      case 0: // Campaign Configuration
        return formData.name && formData.id && formData.platforms.length > 0 && 
               (formData.keywords.length > 0 || formData.hashtags.length > 0);
      case 1: // Resource Allocation
        return formData.crawlerAgents.length > 0 && formData.consensusAgentCount > 0 && formData.budget > 0;
      case 2: // Wallet Setup
        return formData.walletConnected && formData.solBalance >= 0.002;
      case 3: // JuliaOS Access
        return formData.juliaOSAccount && formData.apiKey;
      default:
        return false;
    }
  };

  const canProceedToNextStep = () => {
    return isStepValid(currentStep);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0A0F1F] via-[#1A1F2F] to-[#0A0F1F] p-6">
      <div className="max-w-6xl mx-auto space-y-8">
        {/* Header */}
        <div className="text-center space-y-4">
          <motion.h1 
            className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-purple-400 via-blue-400 to-cyan-400 bg-clip-text text-transparent"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            Create Campaign
          </motion.h1>
          <motion.p 
            className="text-gray-400 text-lg max-w-2xl mx-auto"
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            Configure your decentralized content monitoring campaign with AI agents
          </motion.p>
        </div>

        {/* Progress Steps */}
        <div className="flex justify-center">
          <div className="flex space-x-4">
            {steps.map((step, index) => (
              <motion.div
                key={step.id}
                className={`flex items-center space-x-2 ${
                  index <= currentStep ? 'text-white' : 'text-gray-500'
                }`}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
              >
                <div className={`w-8 h-8 rounded-full flex items-center justify-center border-2 ${
                  index <= currentStep 
                    ? 'border-purple-500 bg-purple-500/20' 
                    : 'border-gray-600 bg-gray-800/50'
                }`}>
                  <step.icon className="w-4 h-4" />
                </div>
                <span className="hidden md:block text-sm font-medium">{step.title}</span>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Main Form */}
        <Card className="glassmorphism border-purple-500/20">
          <CardContent className="p-8">
            {renderStep()}
          </CardContent>
        </Card>

        {/* Success/Error Messages */}
        {successMessage && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="p-6 rounded-lg bg-green-500/20 border border-green-500/30"
          >
            <div className="flex items-start space-x-3">
              <CheckCircle className="w-6 h-6 text-green-400 mt-1" />
              <div className="flex-1">
                <h3 className="text-green-400 font-semibold mb-2">Campaign Created Successfully!</h3>
                <p className="text-green-300 text-sm mb-3">{successMessage}</p>
                {nftSignature && (
                  <div className="bg-green-500/10 rounded-lg p-3">
                    <div className="flex items-center space-x-2 mb-2">
                      <Sparkles className="w-4 h-4 text-green-400" />
                      <span className="text-green-400 font-medium">Access NFT Minted</span>
                    </div>
                    <p className="text-xs text-green-300 font-mono">
                      Signature: {nftSignature.slice(0, 20)}...{nftSignature.slice(-20)}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </motion.div>
        )}

        {errorMessage && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="p-4 rounded-lg bg-red-500/20 border border-red-500/30"
          >
            <div className="flex items-center space-x-2">
              <AlertCircle className="w-5 h-5 text-red-400" />
              <span className="text-red-400 font-medium">{errorMessage}</span>
            </div>
          </motion.div>
        )}

        {contractError && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="p-4 rounded-lg bg-orange-500/20 border border-orange-500/30"
          >
            <div className="flex items-center space-x-2">
              <AlertTriangle className="w-5 h-5 text-orange-400" />
              <span className="text-orange-400 font-medium">NFT Minting Error: {contractError}</span>
            </div>
          </motion.div>
        )}

        {/* Navigation */}
        <div className="flex justify-between items-center">
          <Button
            variant="outline"
            onClick={handlePreviousStep}
            disabled={currentStep === 0}
          >
            Previous
          </Button>

          <div className="flex space-x-4">
            {currentStep < steps.length - 1 ? (
              <Button
                onClick={handleNextStep}
                disabled={!canProceedToNextStep()}
                className={`${
                  canProceedToNextStep() 
                    ? 'bg-gradient-to-r from-purple-500 to-blue-500' 
                    : 'bg-gray-600 cursor-not-allowed'
                }`}
              >
                Next Step
              </Button>
            ) : (
              <Button
                onClick={handleSubmit}
                disabled={isSubmitting || !formData.walletConnected || contractLoading}
                className="bg-gradient-to-r from-green-500 to-blue-500"
              >
                {isSubmitting || contractLoading ? (
                  <div className="flex items-center space-x-2">
                    <Loader2 className="w-4 h-4 animate-spin" />
                    <span>{isSubmitting ? 'Creating Campaign...' : 'Minting NFT...'}</span>
                  </div>
                ) : (
                  'Create Campaign & Mint NFT'
                )}
              </Button>
            )}
          </div>
        </div>

        {/* Requirements Summary */}
        <Card className="glassmorphism border-blue-500/20">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Info className="w-5 h-5 text-blue-400" />
              <span>Campaign Requirements Summary</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="space-y-2">
                <h4 className="font-semibold text-white">Campaign Configuration</h4>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• Name/ID (medterra_summer_launch)</li>
                  <li>• Platforms to monitor</li>
                  <li>• Target keywords/hashtags</li>
                  <li>• Alert thresholds</li>
                </ul>
              </div>
              
              <div className="space-y-2">
                <h4 className="font-semibold text-white">Resource Allocation</h4>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• Agent types/count</li>
                  <li>• Budget for operations</li>
                  <li>• Gas + LLM costs</li>
                </ul>
              </div>
              
              <div className="space-y-2">
                <h4 className="font-semibold text-white">Wallet Essentials</h4>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• SOL for NFT minting (~0.0018 SOL)</li>
                  <li>• Connected Web3 wallet</li>
                </ul>
              </div>
              
              <div className="space-y-2">
                <h4 className="font-semibold text-white">JuliaOS Access</h4>
                <ul className="text-sm text-gray-400 space-y-1">
                  <li>• Account on JuliaOS platform</li>
                  <li>• API keys for agent deployment</li>
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
