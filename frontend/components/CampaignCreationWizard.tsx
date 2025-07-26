'use client';

import { motion } from 'framer-motion';
import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { 
  Wallet, 
  Database, 
  Server, 
  CheckCircle, 
  Clock, 
  Zap,
  ArrowRight,
  Activity,
  Globe,
  Cpu,
  Shield,
  Settings,
  Play,
  BarChart3
} from 'lucide-react';

interface WizardStep {
  id: string;
  title: string;
  description: string;
  icon: React.ReactNode;
  status: 'pending' | 'active' | 'completed' | 'failed';
  details: string[];
}

export default function CampaignCreationWizard() {
  const [currentStep, setCurrentStep] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  const steps: WizardStep[] = [
    {
      id: 'nft-mint',
      title: 'NFT Minting',
      description: 'Create your campaign access token',
      icon: <Wallet className="w-5 h-5" />,
      status: 'pending',
      details: [
        'Deploy campaign configuration to IPFS',
        'Mint JOS-ACCESS NFT with metadata URI',
        'NFT contains campaign parameters and settings',
        'Token serves as access key to campaign dashboard'
      ]
    },
    {
      id: 'wallet-connect',
      title: 'Wallet Connection',
      description: 'Connect wallet to verify NFT ownership',
      icon: <Database className="w-5 h-5" />,
      status: 'pending',
      details: [
        'User connects Solana wallet to dashboard',
        'System queries wallet for JOS-ACCESS NFTs',
        'Verifies NFT ownership and metadata',
        'Extracts campaign configuration from IPFS'
      ]
    },
    {
      id: 'campaign-init',
      title: 'Campaign Initialization',
      description: 'Load and parse campaign configuration',
      icon: <Server className="w-5 h-5" />,
      status: 'pending',
      details: [
        'Fetch config from NFT metadata URI',
        'Parse platforms, keywords, and thresholds',
        'Validate campaign parameters',
        'Prepare agent deployment configuration'
      ]
    },
    {
      id: 'agent-deploy',
      title: 'Agent Deployment',
      description: 'Deploy AI agents to decentralized network',
      icon: <Zap className="w-5 h-5" />,
      status: 'pending',
      details: [
        'Create crawler agents for each platform',
        'Deploy analyzer agents for sentiment analysis',
        'Initialize validator swarm for consensus',
        'Link agents to NFT campaign ID'
      ]
    },
    {
      id: 'dashboard-activate',
      title: 'Dashboard Activation',
      description: 'Enable real-time monitoring and controls',
      icon: <BarChart3 className="w-5 h-5" />,
      status: 'pending',
      details: [
        'Activate real-time data collection',
        'Enable agent control panel',
        'Initialize analytics dashboard',
        'Start monitoring and alerting system'
      ]
    }
  ];

  const startWizard = () => {
    setIsRunning(true);
    setCurrentStep(0);
    
    steps.forEach((step, index) => {
      setTimeout(() => {
        setCurrentStep(index);
        
        // Mark step as active
        const updatedSteps = [...steps];
        updatedSteps[index].status = 'active';
        
        // Mark previous steps as completed
        for (let i = 0; i < index; i++) {
          updatedSteps[i].status = 'completed';
        }
        
        // Mark current step as completed after duration
        setTimeout(() => {
          updatedSteps[index].status = 'completed';
        }, 2000);
        
      }, index * 2500);
    });
  };

  const getStepStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-500';
      case 'active': return 'bg-blue-500';
      case 'failed': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  const getStepStatusText = (status: string) => {
    switch (status) {
      case 'completed': return 'Completed';
      case 'active': return 'Active';
      case 'failed': return 'Failed';
      default: return 'Pending';
    }
  };

  return (
    <Card className="glassmorphism border-purple-500/20">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Activity className="w-5 h-5 text-purple-400" />
          <span>Campaign Creation Wizard</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Progress Bar */}
        <div className="space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm font-medium">Creation Progress</span>
            <Badge variant="secondary" className="bg-blue-500/20 text-blue-400">
              Step {currentStep + 1} of {steps.length}
            </Badge>
          </div>
          <Progress value={((currentStep + 1) / steps.length) * 100} className="h-2" />
        </div>

        {/* Steps */}
        <div className="space-y-4">
          {steps.map((step, index) => (
            <motion.div
              key={step.id}
              className={`p-4 rounded-lg border-2 transition-all duration-300 ${
                step.status === 'completed' ? 'border-green-500/50 bg-green-500/10' :
                step.status === 'active' ? 'border-blue-500/50 bg-blue-500/10' :
                'border-gray-500/50 bg-gray-800/30'
              }`}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
            >
              <div className="flex items-start space-x-4">
                {/* Step Icon */}
                <motion.div
                  className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${
                    step.status === 'completed' ? 'border-green-500 bg-green-500/20' :
                    step.status === 'active' ? 'border-blue-500 bg-blue-500/20' :
                    'border-gray-500 bg-gray-800/50'
                  }`}
                  animate={{
                    scale: step.status === 'active' ? [1, 1.1, 1] : 1,
                    boxShadow: step.status === 'active' 
                      ? '0 0 20px rgba(59, 130, 246, 0.5)' 
                      : '0 0 0px rgba(59, 130, 246, 0)'
                  }}
                  transition={{ duration: 1, repeat: step.status === 'active' ? Infinity : 0 }}
                >
                  <div className={`${
                    step.status === 'completed' ? 'text-green-400' :
                    step.status === 'active' ? 'text-blue-400' :
                    'text-gray-400'
                  }`}>
                    {step.icon}
                  </div>
                </motion.div>

                {/* Step Content */}
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="font-semibold text-white">{step.title}</h3>
                    <Badge 
                      variant="secondary" 
                      className={`text-xs ${
                        step.status === 'completed' ? 'bg-green-500/20 text-green-400' :
                        step.status === 'active' ? 'bg-blue-500/20 text-blue-400' :
                        'bg-gray-500/20 text-gray-400'
                      }`}
                    >
                      {getStepStatusText(step.status)}
                    </Badge>
                  </div>
                  <p className="text-sm text-gray-400 mb-3">{step.description}</p>
                  
                  {/* Step Details */}
                  <div className="space-y-1">
                    {step.details.map((detail, detailIndex) => (
                      <motion.div
                        key={detailIndex}
                        className="flex items-center space-x-2 text-xs text-gray-300"
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: (index * 0.1) + (detailIndex * 0.1) }}
                      >
                        <div className={`w-1 h-1 rounded-full ${
                          step.status === 'completed' ? 'bg-green-400' :
                          step.status === 'active' ? 'bg-blue-400' :
                          'bg-gray-500'
                        }`} />
                        <span>{detail}</span>
                      </motion.div>
                    ))}
                  </div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Technical Architecture */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <div className="space-y-4">
            <h4 className="font-semibold text-white flex items-center space-x-2">
              <Globe className="w-4 h-4 text-blue-400" />
              <span>Platform Integration</span>
            </h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-400">Twitter API:</span>
                <span className="text-green-400">Connected</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Reddit API:</span>
                <span className="text-green-400">Connected</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">IPFS Gateway:</span>
                <span className="text-green-400">Active</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Solana RPC:</span>
                <span className="text-green-400">Connected</span>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <h4 className="font-semibold text-white flex items-center space-x-2">
              <Cpu className="w-4 h-4 text-green-400" />
              <span>Agent Types</span>
            </h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-400">Crawler Agents:</span>
                <span className="text-blue-400">2 Deployed</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Analyzer Agents:</span>
                <span className="text-green-400">1 Active</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Validator Agents:</span>
                <span className="text-purple-400">4 Swarm</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Total Agents:</span>
                <span className="text-white">7</span>
              </div>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex justify-center space-x-4 pt-6">
          <motion.button
            className="bg-gradient-to-r from-purple-500 to-blue-500 hover:from-blue-500 hover:to-purple-500 px-6 py-3 rounded-lg font-semibold text-white shadow-lg"
            onClick={startWizard}
            disabled={isRunning}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            {isRunning ? 'Creating Campaign...' : 'Start Campaign Creation'}
          </motion.button>
          
          <Button variant="outline" className="px-6 py-3">
            <Settings className="w-4 h-4 mr-2" />
            Configure
          </Button>
        </div>

        {/* Status Messages */}
        {isRunning && (
          <motion.div
            className="mt-6 p-4 rounded-lg bg-blue-500/10 border border-blue-500/20"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-center space-x-2">
              <Clock className="w-4 h-4 text-blue-400" />
              <span className="text-sm text-blue-400">
                {steps[currentStep]?.title} - {steps[currentStep]?.description}
              </span>
            </div>
          </motion.div>
        )}
      </CardContent>
    </Card>
  );
} 