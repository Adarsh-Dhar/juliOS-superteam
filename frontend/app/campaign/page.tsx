'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { WalletMultiButton } from "@solana/wallet-adapter-react-ui";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { useCampaignNFT } from '@/hooks/useCampaignNFT';
import NFTVerificationFlow from '@/components/NFTVerificationFlow';
import AgentDeploymentVisual from '@/components/AgentDeploymentVisual';
import CampaignCreationWizard from '@/components/CampaignCreationWizard';
import { 
  Activity, 
  TrendingUp, 
  AlertTriangle, 
  CheckCircle, 
  Clock, 
  Zap,
  BarChart3,
  Settings,
  Play,
  Pause,
  RotateCcw,
  Eye,
  Download,
  Share2,
  Shield,
  Globe,
  Cpu
} from 'lucide-react';

export default function CampaignPage() {
  const { publicKey, connected } = useWallet();
  const {
    campaignNFT,
    isLoading,
    deploymentStatus,
    agents,
    metrics,
    startCampaignFlow,
    pauseAllAgents,
    resumeAllAgents,
    redeployAgents
  } = useCampaignNFT();

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'online': return 'bg-green-500';
      case 'initializing': return 'bg-yellow-500';
      case 'pending': return 'bg-gray-500';
      case 'offline': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'online': return 'Online';
      case 'initializing': return 'Initializing';
      case 'pending': return 'Pending';
      case 'offline': return 'Offline';
      default: return 'Unknown';
    }
  };

  if (!connected) {
    return (
      <div className="min-h-screen bg-[#0A0F1F] flex items-center justify-center">
        <Card className="w-full max-w-md glassmorphism border-purple-500/20">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl font-orbitron text-white">Campaign Access Required</CardTitle>
            <CardDescription className="text-gray-400">
              Connect your wallet to access your campaign dashboard
            </CardDescription>
          </CardHeader>
          <CardContent className="flex justify-center">
            <WalletMultiButton />
          </CardContent>
        </Card>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#0A0F1F] flex items-center justify-center">
        <Card className="w-full max-w-lg glassmorphism border-purple-500/20">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl font-orbitron text-white mb-4">
              {deploymentStatus === 'verifying' && 'Verifying NFT Access...'}
              {deploymentStatus === 'initializing' && 'Initializing Campaign...'}
              {deploymentStatus === 'deploying' && 'Deploying Agents...'}
            </CardTitle>
            <CardDescription className="text-gray-400">
              {deploymentStatus === 'verifying' && 'Checking NFT ownership and metadata'}
              {deploymentStatus === 'initializing' && 'Loading campaign configuration from IPFS'}
              {deploymentStatus === 'deploying' && 'Deploying AI agents to decentralized network'}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <Progress value={
              deploymentStatus === 'verifying' ? 25 :
              deploymentStatus === 'initializing' ? 50 :
              deploymentStatus === 'deploying' ? 75 : 100
            } className="h-2" />
            <div className="flex items-center justify-center space-x-2 text-sm text-gray-400">
              <div className={`w-2 h-2 rounded-full ${deploymentStatus === 'verifying' ? 'bg-blue-500' : 'bg-gray-500'}`} />
              <span>NFT Verification</span>
              <div className={`w-2 h-2 rounded-full ${deploymentStatus === 'initializing' ? 'bg-blue-500' : 'bg-gray-500'}`} />
              <span>Campaign Init</span>
              <div className={`w-2 h-2 rounded-full ${deploymentStatus === 'deploying' ? 'bg-blue-500' : 'bg-gray-500'}`} />
              <span>Agent Deploy</span>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0A0F1F] text-white">
      {/* Header */}
      <motion.header
        className="border-b border-gray-800/50 bg-black/20 backdrop-blur-sm"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <h1 className="text-2xl font-orbitron font-bold holographic-text">
                Campaign Dashboard
              </h1>
              <Badge variant="secondary" className="bg-green-500/20 text-green-400 border-green-500/30">
                <CheckCircle className="w-3 h-3 mr-1" />
                Active
              </Badge>
            </div>
            <div className="flex items-center space-x-4">
              <WalletMultiButton />
            </div>
          </div>
        </div>
      </motion.header>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        <Tabs defaultValue="dashboard" className="w-full">
          <TabsList className="grid w-full grid-cols-5 mb-8">
            <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
            <TabsTrigger value="wizard">Creation Wizard</TabsTrigger>
            <TabsTrigger value="verification">NFT Verification</TabsTrigger>
            <TabsTrigger value="deployment">Agent Deployment</TabsTrigger>
            <TabsTrigger value="analytics">Analytics</TabsTrigger>
          </TabsList>

          {/* Dashboard Tab */}
          <TabsContent value="dashboard" className="space-y-8">
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Left Column - Campaign Info & Controls */}
              <div className="lg:col-span-1 space-y-6">
                {/* Campaign NFT Info */}
                <Card className="glassmorphism border-purple-500/20">
                  <CardHeader>
                    <CardTitle className="flex items-center space-x-2">
                      <Activity className="w-5 h-5 text-purple-400" />
                      <span>Campaign NFT</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <div className="flex justify-between">
                        <span className="text-gray-400">Name:</span>
                        <span className="font-semibold">{campaignNFT?.metadata.name}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Symbol:</span>
                        <span className="font-semibold">{campaignNFT?.symbol}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Address:</span>
                        <span className="text-xs font-mono text-gray-300">
                          {campaignNFT?.address.slice(0, 8)}...{campaignNFT?.address.slice(-8)}
                        </span>
                      </div>
                    </div>
                    <Separator />
                    <div className="space-y-2">
                      <div className="flex justify-between">
                        <span className="text-gray-400">Platforms:</span>
                        <div className="flex space-x-1">
                          {campaignNFT?.metadata.platforms.map(platform => (
                            <Badge key={platform} variant="outline" className="text-xs">
                              {platform}
                            </Badge>
                          ))}
                        </div>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-400">Keywords:</span>
                        <div className="flex space-x-1">
                          {campaignNFT?.metadata.keywords.map(keyword => (
                            <Badge key={keyword} variant="outline" className="text-xs">
                              {keyword}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                {/* Agent Status */}
                <Card className="glassmorphism border-purple-500/20">
                  <CardHeader>
                    <CardTitle className="flex items-center space-x-2">
                      <Zap className="w-5 h-5 text-blue-400" />
                      <span>Agent Status</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {agents.map(agent => (
                        <div key={agent.id} className="flex items-center justify-between p-3 rounded-lg bg-gray-800/30">
                          <div className="flex items-center space-x-3">
                            <div className={`w-3 h-3 rounded-full ${getStatusColor(agent.status)}`} />
                            <div>
                              <div className="font-medium text-sm">
                                {agent.type.charAt(0).toUpperCase() + agent.type.slice(1)} Agent
                              </div>
                              {agent.platform && (
                                <div className="text-xs text-gray-400">{agent.platform}</div>
                              )}
                            </div>
                          </div>
                          <div className="text-right">
                            <div className="text-sm font-medium">{getStatusText(agent.status)}</div>
                            {agent.performance > 0 && (
                              <div className="text-xs text-gray-400">{agent.performance}%</div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                {/* Control Panel */}
                <Card className="glassmorphism border-purple-500/20">
                  <CardHeader>
                    <CardTitle className="flex items-center space-x-2">
                      <Settings className="w-5 h-5 text-green-400" />
                      <span>Control Panel</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <Button 
                      className="w-full bg-gradient-to-r from-purple-500 to-blue-500 hover:from-blue-500 hover:to-purple-500"
                      onClick={resumeAllAgents}
                    >
                      <Play className="w-4 h-4 mr-2" />
                      Resume All Agents
                    </Button>
                    <Button variant="outline" className="w-full" onClick={pauseAllAgents}>
                      <Pause className="w-4 h-4 mr-2" />
                      Pause All Agents
                    </Button>
                    <Button variant="outline" className="w-full" onClick={redeployAgents}>
                      <RotateCcw className="w-4 h-4 mr-2" />
                      Redeploy Agents
                    </Button>
                    <Separator />
                    <Button variant="outline" className="w-full">
                      <Eye className="w-4 h-4 mr-2" />
                      View Raw Data
                    </Button>
                    <Button variant="outline" className="w-full">
                      <Download className="w-4 h-4 mr-2" />
                      Export Report
                    </Button>
                    <Button variant="outline" className="w-full">
                      <Share2 className="w-4 h-4 mr-2" />
                      Share Dashboard
                    </Button>
                  </CardContent>
                </Card>
              </div>

              {/* Right Column - Analytics & Metrics */}
              <div className="lg:col-span-2 space-y-6">
                {/* Real-time Metrics */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <Card className="glassmorphism border-green-500/20">
                    <CardContent className="p-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm text-gray-400">Posts Analyzed</p>
                          <p className="text-2xl font-bold text-white">{metrics.postsAnalyzed.toLocaleString()}</p>
                        </div>
                        <TrendingUp className="w-8 h-8 text-green-400" />
                      </div>
                      <div className="mt-2 flex items-center text-sm">
                        <span className="text-green-400">↑ 12%</span>
                        <span className="text-gray-400 ml-1">from last hour</span>
                      </div>
                    </CardContent>
                  </Card>

                  <Card className="glassmorphism border-blue-500/20">
                    <CardContent className="p-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm text-gray-400">Avg. Sentiment</p>
                          <p className="text-2xl font-bold text-white">{(metrics.avgSentiment * 100).toFixed(1)}%</p>
                        </div>
                        <BarChart3 className="w-8 h-8 text-blue-400" />
                      </div>
                      <div className="mt-2 flex items-center text-sm">
                        <span className={metrics.sentimentTrend === 'up' ? 'text-green-400' : metrics.sentimentTrend === 'down' ? 'text-red-400' : 'text-gray-400'}>
                          {metrics.sentimentTrend === 'up' ? '↑' : metrics.sentimentTrend === 'down' ? '↓' : '→'} Stable
                        </span>
                      </div>
                    </CardContent>
                  </Card>

                  <Card className="glassmorphism border-red-500/20">
                    <CardContent className="p-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <p className="text-sm text-gray-400">Spam Detected</p>
                          <p className="text-2xl font-bold text-white">{metrics.spamDetected.toFixed(1)}%</p>
                        </div>
                        <AlertTriangle className="w-8 h-8 text-red-400" />
                      </div>
                      <div className="mt-2 flex items-center text-sm">
                        <span className="text-red-400">↓ 2%</span>
                        <span className="text-gray-400 ml-1">from last hour</span>
                      </div>
                    </CardContent>
                  </Card>
                </div>

                {/* Agent Deployment Chart */}
                <Card className="glassmorphism border-purple-500/20">
                  <CardHeader>
                    <CardTitle className="flex items-center space-x-2">
                      <Zap className="w-5 h-5 text-yellow-400" />
                      <span>Agent Deployment Status</span>
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div className="text-center p-4 rounded-lg bg-green-500/10 border border-green-500/20">
                        <div className="text-2xl font-bold text-green-400">
                          {agents.filter(a => a.status === 'online').length}
                        </div>
                        <div className="text-sm text-gray-400">Online</div>
                      </div>
                      <div className="text-center p-4 rounded-lg bg-yellow-500/10 border border-yellow-500/20">
                        <div className="text-2xl font-bold text-yellow-400">
                          {agents.filter(a => a.status === 'initializing').length}
                        </div>
                        <div className="text-sm text-gray-400">Initializing</div>
                      </div>
                      <div className="text-center p-4 rounded-lg bg-gray-500/10 border border-gray-500/20">
                        <div className="text-2xl font-bold text-gray-400">
                          {agents.filter(a => a.status === 'pending').length}
                        </div>
                        <div className="text-sm text-gray-400">Pending</div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </div>
          </TabsContent>

          {/* Creation Wizard Tab */}
          <TabsContent value="wizard" className="space-y-8">
            <CampaignCreationWizard />
          </TabsContent>

          {/* NFT Verification Tab */}
          <TabsContent value="verification" className="space-y-8">
            <NFTVerificationFlow />
          </TabsContent>

          {/* Agent Deployment Tab */}
          <TabsContent value="deployment" className="space-y-8">
            <AgentDeploymentVisual />
          </TabsContent>

          {/* Analytics Tab */}
          <TabsContent value="analytics" className="space-y-8">
            <Card className="glassmorphism border-purple-500/20">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <BarChart3 className="w-5 h-5 text-purple-400" />
                  <span>Real-time Analytics</span>
                </CardTitle>
              </CardHeader>
              <CardContent>
                <Tabs defaultValue="overview" className="w-full">
                  <TabsList className="grid w-full grid-cols-4">
                    <TabsTrigger value="overview">Overview</TabsTrigger>
                    <TabsTrigger value="sentiment">Sentiment</TabsTrigger>
                    <TabsTrigger value="platforms">Platforms</TabsTrigger>
                    <TabsTrigger value="alerts">Alerts</TabsTrigger>
                  </TabsList>
                  
                  <TabsContent value="overview" className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <h4 className="font-semibold">Performance Metrics</h4>
                        <div className="space-y-2 text-sm">
                          <div className="flex justify-between">
                            <span>Accuracy Rate:</span>
                            <span className="text-green-400">98.7%</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Response Time:</span>
                            <span className="text-blue-400">2.3s</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Uptime:</span>
                            <span className="text-green-400">99.9%</span>
                          </div>
                        </div>
                      </div>
                      <div className="space-y-2">
                        <h4 className="font-semibold">Alert Thresholds</h4>
                        <div className="space-y-2 text-sm">
                          <div className="flex justify-between">
                            <span>Spam Threshold:</span>
                            <span>{campaignNFT?.metadata.alert_thresholds.spam}%</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Sentiment Drop:</span>
                            <span>{campaignNFT?.metadata.alert_thresholds.sentiment_drop}%</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </TabsContent>
                  
                  <TabsContent value="sentiment" className="space-y-4">
                    <div className="h-32 bg-gray-800/30 rounded-lg flex items-center justify-center">
                      <span className="text-gray-400">Sentiment Analysis Chart</span>
                    </div>
                  </TabsContent>
                  
                  <TabsContent value="platforms" className="space-y-4">
                    <div className="space-y-3">
                      {campaignNFT?.metadata.platforms.map(platform => (
                        <div key={platform} className="flex items-center justify-between p-3 rounded-lg bg-gray-800/30">
                          <span className="capitalize">{platform}</span>
                          <div className="flex items-center space-x-2">
                            <div className="w-2 h-2 rounded-full bg-green-500"></div>
                            <span className="text-sm text-green-400">Active</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </TabsContent>
                  
                  <TabsContent value="alerts" className="space-y-4">
                    <Alert>
                      <AlertTriangle className="h-4 w-4" />
                      <AlertDescription>
                        Sentiment drop detected on Twitter - 25% decrease in positive mentions
                      </AlertDescription>
                    </Alert>
                    <Alert>
                      <AlertTriangle className="h-4 w-4" />
                      <AlertDescription>
                        Spam activity increased to 12% on Reddit
                      </AlertDescription>
                    </Alert>
                  </TabsContent>
                </Tabs>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
