'use client';

import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { 
  Zap, 
  Activity, 
  Server, 
  Globe, 
  Cpu, 
  Network,
  CheckCircle,
  Clock,
  AlertTriangle
} from 'lucide-react';

interface Agent {
  id: string;
  type: 'crawler' | 'analyzer' | 'validator';
  status: 'deploying' | 'online' | 'offline' | 'failed';
  platform?: string;
  performance: number;
  position: { x: number; y: number };
}

export default function AgentDeploymentVisual() {
  const [agents, setAgents] = useState<Agent[]>([]);
  const [deploymentProgress, setDeploymentProgress] = useState(0);
  const [isDeploying, setIsDeploying] = useState(false);

  const startDeployment = () => {
    setIsDeploying(true);
    setDeploymentProgress(0);
    
    // Initialize agents with random positions
    const initialAgents: Agent[] = [
      { id: 'crawler-1', type: 'crawler', status: 'deploying', platform: 'twitter', performance: 0, position: { x: 20, y: 30 } },
      { id: 'crawler-2', type: 'crawler', status: 'deploying', platform: 'reddit', performance: 0, position: { x: 80, y: 30 } },
      { id: 'analyzer-1', type: 'analyzer', status: 'deploying', performance: 0, position: { x: 50, y: 50 } },
      { id: 'validator-1', type: 'validator', status: 'deploying', performance: 0, position: { x: 20, y: 70 } },
      { id: 'validator-2', type: 'validator', status: 'deploying', performance: 0, position: { x: 80, y: 70 } },
      { id: 'validator-3', type: 'validator', status: 'deploying', performance: 0, position: { x: 35, y: 85 } },
      { id: 'validator-4', type: 'validator', status: 'deploying', performance: 0, position: { x: 65, y: 85 } },
    ];
    
    setAgents(initialAgents);

    // Simulate deployment progress
    const interval = setInterval(() => {
      setDeploymentProgress(prev => {
        if (prev >= 100) {
          clearInterval(interval);
          setIsDeploying(false);
          return 100;
        }
        return prev + 2;
      });
    }, 100);

    // Simulate agent status changes
    setTimeout(() => {
      setAgents(prev => prev.map(agent => ({ ...agent, status: 'online' as const, performance: Math.floor(Math.random() * 30) + 70 })));
    }, 2000);

    setTimeout(() => {
      setAgents(prev => prev.map(agent => ({ ...agent, performance: Math.floor(Math.random() * 20) + 80 })));
    }, 4000);
  };

  const getAgentIcon = (type: string) => {
    switch (type) {
      case 'crawler': return <Globe className="w-4 h-4" />;
      case 'analyzer': return <Cpu className="w-4 h-4" />;
      case 'validator': return <Server className="w-4 h-4" />;
      default: return <Activity className="w-4 h-4" />;
    }
  };

  const getAgentColor = (type: string) => {
    switch (type) {
      case 'crawler': return 'text-blue-400';
      case 'analyzer': return 'text-green-400';
      case 'validator': return 'text-purple-400';
      default: return 'text-gray-400';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'online': return 'bg-green-500';
      case 'deploying': return 'bg-yellow-500';
      case 'failed': return 'bg-red-500';
      default: return 'bg-gray-500';
    }
  };

  return (
    <Card className="glassmorphism border-purple-500/20">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2">
          <Zap className="w-5 h-5 text-yellow-400" />
          <span>Agent Deployment Visualization</span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Deployment Progress */}
        <div className="space-y-3">
          <div className="flex justify-between items-center">
            <span className="text-sm font-medium">Deployment Progress</span>
            <Badge variant="secondary" className="bg-blue-500/20 text-blue-400">
              {deploymentProgress}%
            </Badge>
          </div>
          <Progress value={deploymentProgress} className="h-2" />
          <div className="flex justify-center">
            <motion.button
              className="bg-gradient-to-r from-purple-500 to-blue-500 hover:from-blue-500 hover:to-purple-500 px-4 py-2 rounded-lg font-semibold text-white"
              onClick={startDeployment}
              disabled={isDeploying}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              {isDeploying ? 'Deploying...' : 'Start Deployment'}
            </motion.button>
          </div>
        </div>

        {/* Agent Network Visualization */}
        <div className="relative h-64 bg-gray-900/50 rounded-lg border border-gray-700/50 overflow-hidden">
          {/* Network Grid */}
          <div className="absolute inset-0 opacity-20">
            <svg width="100%" height="100%">
              <defs>
                <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
                  <path d="M 20 0 L 0 0 0 20" fill="none" stroke="currentColor" strokeWidth="0.5" className="text-gray-600"/>
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#grid)" />
            </svg>
          </div>

          {/* Central Hub */}
          <motion.div
            className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-16 h-16 bg-gradient-to-r from-purple-500 to-blue-500 rounded-full flex items-center justify-center"
            animate={{
              scale: [1, 1.1, 1],
              boxShadow: ['0 0 10px rgba(139, 92, 246, 0.3)', '0 0 20px rgba(139, 92, 246, 0.5)', '0 0 10px rgba(139, 92, 246, 0.3)']
            }}
            transition={{ duration: 2, repeat: Infinity }}
          >
            <Network className="w-6 h-6 text-white" />
          </motion.div>

          {/* Agents */}
          {agents.map((agent, index) => (
            <motion.div
              key={agent.id}
              className="absolute w-8 h-8 rounded-full flex items-center justify-center border-2"
              style={{
                left: `${agent.position.x}%`,
                top: `${agent.position.y}%`,
                transform: 'translate(-50%, -50%)'
              }}
              initial={{ scale: 0, opacity: 0 }}
              animate={{ 
                scale: 1, 
                opacity: 1,
                boxShadow: agent.status === 'online' 
                  ? '0 0 15px rgba(34, 197, 94, 0.5)' 
                  : '0 0 0px rgba(34, 197, 94, 0)'
              }}
              transition={{ delay: index * 0.2 }}
            >
              <div className={`w-full h-full rounded-full flex items-center justify-center ${
                agent.status === 'online' ? 'bg-green-500/20 border-green-500' :
                agent.status === 'deploying' ? 'bg-yellow-500/20 border-yellow-500' :
                'bg-gray-500/20 border-gray-500'
              }`}>
                <div className={getAgentColor(agent.type)}>
                  {getAgentIcon(agent.type)}
                </div>
              </div>
              
              {/* Status Indicator */}
              <div className={`absolute -top-1 -right-1 w-3 h-3 rounded-full ${getStatusColor(agent.status)}`} />
            </motion.div>
          ))}

          {/* Connection Lines */}
          <svg className="absolute inset-0 w-full h-full pointer-events-none">
            {agents.map((agent) => (
              <motion.line
                key={`line-${agent.id}`}
                x1="50%"
                y1="50%"
                x2={`${agent.position.x}%`}
                y2={`${agent.position.y}%`}
                stroke="currentColor"
                strokeWidth="1"
                className="text-purple-500/30"
                initial={{ pathLength: 0 }}
                animate={{ pathLength: 1 }}
                transition={{ delay: 0.5, duration: 1 }}
              />
            ))}
          </svg>
        </div>

        {/* Agent Status List */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-3">
            <h4 className="font-semibold text-white">Agent Status</h4>
            <div className="space-y-2">
              {agents.map(agent => (
                <div key={agent.id} className="flex items-center justify-between p-2 rounded-lg bg-gray-800/30">
                  <div className="flex items-center space-x-2">
                    <div className={`w-2 h-2 rounded-full ${getStatusColor(agent.status)}`} />
                    <span className="text-sm font-medium">{agent.id}</span>
                    {agent.platform && (
                      <Badge variant="outline" className="text-xs">
                        {agent.platform}
                      </Badge>
                    )}
                  </div>
                  <div className="text-right">
                    <div className="text-xs text-gray-400">{agent.status}</div>
                    {agent.performance > 0 && (
                      <div className="text-xs text-green-400">{agent.performance}%</div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="space-y-3">
            <h4 className="font-semibold text-white">Deployment Stats</h4>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-400">Total Agents:</span>
                <span className="text-white">{agents.length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Online:</span>
                <span className="text-green-400">{agents.filter(a => a.status === 'online').length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Deploying:</span>
                <span className="text-yellow-400">{agents.filter(a => a.status === 'deploying').length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Failed:</span>
                <span className="text-red-400">{agents.filter(a => a.status === 'failed').length}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Avg Performance:</span>
                <span className="text-blue-400">
                  {agents.length > 0 
                    ? Math.round(agents.reduce((sum, a) => sum + a.performance, 0) / agents.length)
                    : 0}%
                </span>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
} 