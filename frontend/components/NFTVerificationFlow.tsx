'use client';

import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Wallet, 
  Database, 
  Server, 
  CheckCircle, 
  Clock, 
  Zap,
  ArrowRight,
  Activity
} from 'lucide-react';

interface VerificationStep {
  id: string;
  name: string;
  description: string;
  status: 'pending' | 'active' | 'completed' | 'failed';
  icon: React.ReactNode;
  duration: number;
}

export default function NFTVerificationFlow() {
  const { publicKey } = useWallet();
  const [currentStep, setCurrentStep] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  const steps: VerificationStep[] = [
    {
      id: 'wallet-connect',
      name: 'Wallet Connection',
      description: 'User connects wallet to dashboard',
      status: 'pending',
      icon: <Wallet className="w-5 h-5" />,
      duration: 1000
    },
    {
      id: 'nft-query',
      name: 'NFT Query',
      description: 'Query Solana for wallet NFTs',
      status: 'pending',
      icon: <Database className="w-5 h-5" />,
      duration: 1500
    },
    {
      id: 'metadata-fetch',
      name: 'Metadata Fetch',
      description: 'Fetch NFT metadata from IPFS',
      status: 'pending',
      icon: <Server className="w-5 h-5" />,
      duration: 2000
    },
    {
      id: 'config-parse',
      name: 'Config Parse',
      description: 'Parse campaign configuration',
      status: 'pending',
      icon: <Activity className="w-5 h-5" />,
      duration: 1000
    },
    {
      id: 'agent-deploy',
      name: 'Agent Deployment',
      description: 'Deploy AI agents to network',
      status: 'pending',
      icon: <Zap className="w-5 h-5" />,
      duration: 3000
    },
    {
      id: 'verification-complete',
      name: 'Verification Complete',
      description: 'Campaign ready for monitoring',
      status: 'pending',
      icon: <CheckCircle className="w-5 h-5" />,
      duration: 500
    }
  ];

  const startVerification = () => {
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
        }, step.duration);
        
      }, steps.slice(0, index).reduce((acc, s) => acc + s.duration, 0));
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
          <span>NFT Verification Flow</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Sequence Diagram Visualization */}
        <div className="relative">
          {/* Connection Lines */}
          <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-purple-500/30 to-blue-500/30 transform -translate-y-1/2" />
          
          {/* Steps */}
          <div className="relative flex justify-between items-center">
            {steps.map((step, index) => (
              <motion.div
                key={step.id}
                className="flex flex-col items-center space-y-2"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                {/* Step Circle */}
                <motion.div
                  className={`w-12 h-12 rounded-full flex items-center justify-center border-2 ${
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
                  <motion.div
                    className={`text-white ${
                      step.status === 'completed' ? 'text-green-400' :
                      step.status === 'active' ? 'text-blue-400' :
                      'text-gray-400'
                    }`}
                    animate={{
                      rotate: step.status === 'active' ? [0, 360] : 0
                    }}
                    transition={{ duration: 2, repeat: step.status === 'active' ? Infinity : 0 }}
                  >
                    {step.icon}
                  </motion.div>
                </motion.div>
                
                {/* Step Label */}
                <div className="text-center">
                  <div className="text-sm font-medium text-white">{step.name}</div>
                  <div className="text-xs text-gray-400 max-w-24">{step.description}</div>
                  <Badge 
                    variant="secondary" 
                    className={`mt-1 text-xs ${
                      step.status === 'completed' ? 'bg-green-500/20 text-green-400' :
                      step.status === 'active' ? 'bg-blue-500/20 text-blue-400' :
                      'bg-gray-500/20 text-gray-400'
                    }`}
                  >
                    {getStepStatusText(step.status)}
                  </Badge>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Technical Details */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-8">
          <div className="space-y-3">
            <h4 className="font-semibold text-white">NFT Verification Process</h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-400">Wallet Address:</span>
                <span className="font-mono text-xs text-gray-300">
                  {publicKey?.toString().slice(0, 8)}...{publicKey?.toString().slice(-8)}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">NFT Symbol:</span>
                <span className="text-green-400">JOS-ACCESS</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Metadata URI:</span>
                <span className="font-mono text-xs text-gray-300">ipfs://QmXy...</span>
              </div>
            </div>
          </div>
          
          <div className="space-y-3">
            <h4 className="font-semibold text-white">Agent Deployment</h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-400">Crawler Agents:</span>
                <span className="text-blue-400">2 Online</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Analyzer Agents:</span>
                <span className="text-green-400">1 Online</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Validator Agents:</span>
                <span className="text-yellow-400">4 Deploying</span>
              </div>
            </div>
          </div>
        </div>

        {/* Action Button */}
        <div className="flex justify-center pt-4">
          <motion.button
            className="bg-gradient-to-r from-purple-500 to-blue-500 hover:from-blue-500 hover:to-purple-500 px-6 py-3 rounded-lg font-semibold text-white shadow-lg"
            onClick={startVerification}
            disabled={isRunning}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            {isRunning ? 'Verification Running...' : 'Start Verification Flow'}
          </motion.button>
        </div>

        {/* Status Messages */}
        {isRunning && (
          <motion.div
            className="mt-4 p-4 rounded-lg bg-blue-500/10 border border-blue-500/20"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-center space-x-2">
              <Clock className="w-4 h-4 text-blue-400" />
              <span className="text-sm text-blue-400">
                {steps[currentStep]?.name} - {steps[currentStep]?.description}
              </span>
            </div>
          </motion.div>
        )}
      </CardContent>
    </Card>
  );
} 