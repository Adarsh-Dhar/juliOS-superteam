'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useWallet } from '@solana/wallet-adapter-react';
import { useConnection } from '@solana/wallet-adapter-react';
import { useRouter } from 'next/navigation';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { 
  BarChart3, 
  Calendar, 
  Hash, 
  Users, 
  TrendingUp, 
  Activity,
  Eye,
  Target,
  Globe,
  Cpu,
  Loader2,
  AlertCircle,
  Plus,
  Search,
  Filter
} from 'lucide-react';

interface Campaign {
  id: string;
  name: string;
  hashtag: string;
  description: string;
  startDate: string;
  endDate?: string;
  trustScore: number;
  metadata: {
    platforms?: string[];
    keywords?: string[];
    hashtags?: string[];
    crawlerAgents?: string[];
    consensusAgentCount?: number;
    totalAgents?: number;
    agentDetails?: {
      crawlers: string[];
      consensus: number;
      fixedAnalyzers: string[];
      total: number;
    };
  };
  createdAt: string;
  updatedAt: string;
}

export default function MyCampaignsPage() {
  const { publicKey, connected } = useWallet();
  const { connection } = useConnection();
  const router = useRouter();
  
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');

  // Fetch campaigns for the connected wallet
  useEffect(() => {
    if (!connected || !publicKey) {
      setLoading(false);
      return;
    }

    const fetchCampaigns = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch campaigns from the API
        const response = await fetch('/api/campaigns');
        if (!response.ok) {
          throw new Error('Failed to fetch campaigns');
        }
        
        const data = await response.json();
        setCampaigns(data.campaigns || []);
      } catch (err: any) {
        setError(err.message || 'Failed to load campaigns');
        console.error('Error fetching campaigns:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchCampaigns();
  }, [connected, publicKey]);

  // Filter campaigns based on search and status
  const filteredCampaigns = campaigns.filter(campaign => {
    const matchesSearch = campaign.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         campaign.hashtag.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         campaign.description.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesStatus = statusFilter === 'all' || 
                         (statusFilter === 'active' && !campaign.endDate) ||
                         (statusFilter === 'completed' && campaign.endDate);
    
    return matchesSearch && matchesStatus;
  });

  const handleAnalyticsClick = (campaignId: string) => {
    router.push(`/analytics?campaign=${campaignId}`);
  };

  const handleCreateCampaign = () => {
    router.push('/campaign');
  };

  const getStatusBadge = (campaign: Campaign) => {
    if (campaign.endDate) {
      return <Badge variant="secondary" className="bg-gray-100 text-gray-700">Completed</Badge>;
    }
    return <Badge variant="default" className="bg-green-100 text-green-700">Active</Badge>;
  };

  const getTrustScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-600';
    if (score >= 60) return 'text-yellow-600';
    return 'text-red-600';
  };

  if (!connected) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-center py-20">
            <div className="mb-8">
              <div className="w-24 h-24 bg-slate-200 rounded-full flex items-center justify-center mx-auto mb-4">
                <AlertCircle className="w-12 h-12 text-slate-400" />
              </div>
              <h2 className="text-2xl font-bold text-slate-800 mb-2">Wallet Not Connected</h2>
              <p className="text-slate-600 max-w-md mx-auto">
                Please connect your wallet to view your campaigns and access analytics.
              </p>
            </div>
            <Button size="lg" className="bg-blue-600 hover:bg-blue-700">
              Connect Wallet
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="max-w-7xl mx-auto p-6">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-3xl font-bold text-slate-800 mb-2">My Campaigns</h1>
              <p className="text-slate-600">
                Manage and monitor your social media campaigns
              </p>
            </div>
            <Button 
              onClick={handleCreateCampaign}
              className="bg-blue-600 hover:bg-blue-700"
            >
              <Plus className="w-4 h-4 mr-2" />
              Create Campaign
            </Button>
          </div>

          {/* Search and Filter */}
          <div className="flex flex-col sm:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search campaigns..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-slate-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">All Campaigns</option>
              <option value="active">Active</option>
              <option value="completed">Completed</option>
            </select>
          </div>
        </div>

        {/* Loading State */}
        {loading && (
          <div className="text-center py-20">
            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-blue-600" />
            <p className="text-slate-600">Loading your campaigns...</p>
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="text-center py-20">
            <AlertCircle className="w-12 h-12 text-red-500 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-slate-800 mb-2">Error Loading Campaigns</h3>
            <p className="text-slate-600 mb-4">{error}</p>
            <Button onClick={() => window.location.reload()}>
              Try Again
            </Button>
          </div>
        )}

        {/* Empty State */}
        {!loading && !error && filteredCampaigns.length === 0 && (
          <div className="text-center py-20">
            <div className="w-24 h-24 bg-slate-200 rounded-full flex items-center justify-center mx-auto mb-4">
              <Target className="w-12 h-12 text-slate-400" />
            </div>
            <h3 className="text-xl font-semibold text-slate-800 mb-2">No Campaigns Found</h3>
            <p className="text-slate-600 mb-6 max-w-md mx-auto">
              {searchTerm || statusFilter !== 'all' 
                ? 'No campaigns match your current filters. Try adjusting your search or filters.'
                : 'You haven\'t created any campaigns yet. Start by creating your first campaign.'
              }
            </p>
            {!searchTerm && statusFilter === 'all' && (
              <Button onClick={handleCreateCampaign} className="bg-blue-600 hover:bg-blue-700">
                <Plus className="w-4 h-4 mr-2" />
                Create Your First Campaign
              </Button>
            )}
          </div>
        )}

        {/* Campaigns Grid */}
        {!loading && !error && filteredCampaigns.length > 0 && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredCampaigns.map((campaign, index) => (
              <motion.div
                key={campaign.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.3, delay: index * 0.1 }}
              >
                <Card className="h-full hover:shadow-lg transition-shadow duration-200 border-slate-200">
                  <CardHeader className="pb-4">
                    <div className="flex items-start justify-between mb-2">
                      <CardTitle className="text-lg font-semibold text-slate-800 line-clamp-2">
                        {campaign.name}
                      </CardTitle>
                      {getStatusBadge(campaign)}
                    </div>
                    <CardDescription className="text-slate-600 line-clamp-2">
                      {campaign.description}
                    </CardDescription>
                  </CardHeader>
                  
                  <CardContent className="space-y-4">
                    {/* Campaign Stats */}
                    <div className="grid grid-cols-2 gap-4">
                      <div className="text-center p-3 bg-slate-50 rounded-lg">
                        <div className="text-2xl font-bold text-slate-800">
                          {campaign.metadata?.totalAgents || 0}
                        </div>
                        <div className="text-xs text-slate-600">Agents</div>
                      </div>
                      <div className="text-center p-3 bg-slate-50 rounded-lg">
                        <div className={`text-2xl font-bold ${getTrustScoreColor(campaign.trustScore)}`}>
                          {campaign.trustScore.toFixed(1)}%
                        </div>
                        <div className="text-xs text-slate-600">Trust Score</div>
                      </div>
                    </div>

                    {/* Campaign Details */}
                    <div className="space-y-2">
                      <div className="flex items-center text-sm text-slate-600">
                        <Hash className="w-4 h-4 mr-2" />
                        <span className="font-medium">#{campaign.hashtag}</span>
                      </div>
                      
                      <div className="flex items-center text-sm text-slate-600">
                        <Calendar className="w-4 h-4 mr-2" />
                        <span>Started {new Date(campaign.startDate).toLocaleDateString()}</span>
                      </div>

                      {campaign.metadata?.platforms && campaign.metadata.platforms.length > 0 && (
                        <div className="flex items-center text-sm text-slate-600">
                          <Globe className="w-4 h-4 mr-2" />
                          <span>{campaign.metadata.platforms.join(', ')}</span>
                        </div>
                      )}
                    </div>

                    {/* Action Buttons */}
                    <div className="flex gap-2 pt-2">
                      <Button 
                        onClick={() => handleAnalyticsClick(campaign.id)}
                        className="flex-1 bg-blue-600 hover:bg-blue-700"
                        size="sm"
                      >
                        <BarChart3 className="w-4 h-4 mr-2" />
                        Analytics
                      </Button>
                      <Button 
                        variant="outline" 
                        size="sm"
                        className="border-slate-200 hover:bg-slate-50"
                      >
                        <Eye className="w-4 h-4 mr-2" />
                        View
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        )}

        {/* Summary Stats */}
        {!loading && !error && filteredCampaigns.length > 0 && (
          <div className="mt-8 grid grid-cols-1 md:grid-cols-4 gap-4">
            <Card className="border-slate-200">
              <CardContent className="p-4">
                <div className="flex items-center">
                  <div className="p-2 bg-blue-100 rounded-lg mr-3">
                    <Target className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-slate-800">
                      {filteredCampaigns.length}
                    </div>
                    <div className="text-sm text-slate-600">Total Campaigns</div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="border-slate-200">
              <CardContent className="p-4">
                <div className="flex items-center">
                  <div className="p-2 bg-green-100 rounded-lg mr-3">
                    <Activity className="w-5 h-5 text-green-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-slate-800">
                      {filteredCampaigns.filter(c => !c.endDate).length}
                    </div>
                    <div className="text-sm text-slate-600">Active</div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="border-slate-200">
              <CardContent className="p-4">
                <div className="flex items-center">
                  <div className="p-2 bg-purple-100 rounded-lg mr-3">
                    <Cpu className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-slate-800">
                      {filteredCampaigns.reduce((sum, c) => sum + (c.metadata?.totalAgents || 0), 0)}
                    </div>
                    <div className="text-sm text-slate-600">Total Agents</div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="border-slate-200">
              <CardContent className="p-4">
                <div className="flex items-center">
                  <div className="p-2 bg-yellow-100 rounded-lg mr-3">
                    <TrendingUp className="w-5 h-5 text-yellow-600" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-slate-800">
                      {(filteredCampaigns.reduce((sum, c) => sum + c.trustScore, 0) / filteredCampaigns.length).toFixed(1)}%
                    </div>
                    <div className="text-sm text-slate-600">Avg Trust Score</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
