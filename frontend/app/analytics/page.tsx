"use client";

import React, { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import { motion } from "framer-motion";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card";
import { ChartContainer } from "@/components/ui/chart";
import { useToast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  LineChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Line,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
  ResponsiveContainer
} from "recharts";
import {
  ArrowLeft,
  Calendar,
  Hash,
  TrendingUp,
  Activity,
  Target,
  Users,
  Globe,
  Cpu,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Clock,
  BarChart3,
  Eye,
  MessageSquare,
  Share2,
  Heart,
  Loader2,
  AlertCircle,
  Filter,
  Download,
  RefreshCw
} from "lucide-react";

interface AnalyticsData {
  campaign: {
    id: string;
    name: string;
    hashtag: string;
    description: string;
    startDate: string;
    endDate?: string;
    trustScore: number;
    status: string;
  };
  crawler: {
    totalPosts: number;
    platforms: string[];
    recentActivity: any[];
    crawlStats: {
      twitter: { posts: number; engagement: number };
      reddit: { posts: number; engagement: number };
      total: { posts: number; engagement: number };
    };
    agentStatus: any[];
  };
  analysis: {
    sentiment: {
      positive: number;
      negative: number;
      neutral: number;
      trend: any[];
    };
    trends: {
      keywords: string[];
      hashtags: string[];
      topics: string[];
      trendData: any[];
    };
    engagement: {
      total: number;
      rate: number;
      breakdown: any[];
    };
  };
  consensus: {
    totalAgents: number;
    activeAgents: number;
    consensusScore: number;
    verificationResults: any[];
    agentPerformance: any[];
  };
  performance: {
    totalEngagement: number;
    averageResponseTime: number;
    reach: number;
    impressions: number;
    uniqueUsers: number;
  };
  timeline: {
    posts: any[];
    engagement: any[];
    sentiment: any[];
  };
}

export default function AnalyticsPage() {
  const searchParams = useSearchParams();
  const campaignId = searchParams.get("campaign");
  const { toast } = useToast();
  
  const [analyticsData, setAnalyticsData] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState("overview");

  useEffect(() => {
    if (!campaignId) {
      setError("No campaign ID provided");
      setLoading(false);
      return;
    }

    fetchAnalytics();
  }, [campaignId]);

  const fetchAnalytics = async () => {
    try {
      setLoading(true);
      setError(null);

      console.log('🔍 Fetching analytics for campaign:', campaignId);
      
      const response = await fetch(`/api/analytics/campaign/${campaignId}`);
      if (!response.ok) {
        throw new Error("Failed to fetch analytics");
      }

      const data = await response.json();
      console.log('📊 Analytics data received:', data);
      console.log('📈 Campaign details:', data.campaign);
      console.log('🕷️ Crawler data:', data.crawler);
      console.log('📊 Analysis data:', data.analysis);
      console.log('🤝 Consensus data:', data.consensus);
      console.log('⚡ Performance data:', data.performance);
      console.log('📅 Timeline data:', data.timeline);
      
      setAnalyticsData(data);
    } catch (err: any) {
      console.error('❌ Error fetching analytics:', err);
      setError(err.message);
      toast({
        title: "Error",
        description: "Failed to load analytics data",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = () => {
    fetchAnalytics();
  };

  const handleBack = () => {
    window.history.back();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
        <div className="starfield" />
        <div className="max-w-7xl mx-auto p-6">
          <div className="text-center py-20">
            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-blue-400" />
            <p className="text-gray-400 font-exo2">Loading campaign analytics...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error || !analyticsData) {
    return (
      <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
        <div className="starfield" />
        <div className="max-w-7xl mx-auto p-6">
          <div className="text-center py-20">
            <AlertCircle className="w-12 h-12 text-red-400 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2 font-orbitron">
              Error Loading Analytics
            </h3>
            <p className="text-gray-400 mb-4 font-exo2">{error}</p>
            <div className="flex justify-center space-x-4">
              <Button onClick={handleBack} variant="outline" className="border-gray-600 text-gray-300 hover:bg-gray-800">
                <ArrowLeft className="w-4 h-4 mr-2" />
                Go Back
              </Button>
              <Button onClick={fetchAnalytics} className="bg-gradient-to-r from-purple-500 to-blue-500">
                <RefreshCw className="w-4 h-4 mr-2" />
                Retry
              </Button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  const { campaign, crawler, analysis, consensus, performance, timeline } = analyticsData;

  return (
    <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
      <div className="starfield" />
      <div className="max-w-7xl mx-auto p-6">
        {/* Header */}
        <motion.div 
          className="mb-8"
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-4">
              <Button onClick={handleBack} variant="outline" size="sm" className="border-gray-600 text-gray-300 hover:bg-gray-800">
                <ArrowLeft className="w-4 h-4 mr-2" />
                Back
              </Button>
              <div>
                <h1 className="text-3xl font-bold text-white mb-2 font-orbitron">
                  Campaign Analytics
                </h1>
                <div className="flex items-center space-x-4 text-gray-400 font-exo2">
                  <span className="flex items-center">
                    <Hash className="w-4 h-4 mr-1" />
                    
                  </span>
                  {/* <span className="flex items-center">
                    <Calendar className="w-4 h-4 mr-1" />
                    {new Date(campaign.startDate).toLocaleDateString()}
                  </span> */}
                  <Badge variant={campaign?.status === 'active' ? 'default' : 'secondary'} className="bg-purple-500/20 text-purple-400 border-purple-500/30">
                    {campaign?.status || 'Unknown'}
                  </Badge>
                </div>
              </div>
            </div>
            <div className="flex space-x-2">
              <Button onClick={handleRefresh} variant="outline" size="sm" className="border-gray-600 text-gray-300 hover:bg-gray-800">
                <RefreshCw className="w-4 h-4 mr-2" />
                Refresh
              </Button>
              <Button size="sm" className="bg-gradient-to-r from-purple-500 to-blue-500">
                <Download className="w-4 h-4 mr-2" />
                Export
              </Button>
            </div>
          </div>

          {/* Tab Navigation */}
          <div className="flex space-x-1 border-b border-gray-700">
            {[
              { id: "overview", label: "Overview", icon: BarChart3 },
              { id: "crawler", label: "Crawler", icon: Globe },
              { id: "analysis", label: "Analysis", icon: TrendingUp },
              { id: "consensus", label: "Consensus", icon: Cpu },
              { id: "timeline", label: "Timeline", icon: Activity },
            ].map((tab) => (
              <Button
                key={tab.id}
                variant={activeTab === tab.id ? "default" : "ghost"}
                size="sm"
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-2 ${
                  activeTab === tab.id 
                    ? 'bg-gradient-to-r from-purple-500 to-blue-500 text-white' 
                    : 'text-gray-400 hover:text-white hover:bg-gray-800'
                }`}
              >
                <tab.icon className="w-4 h-4" />
                <span className="font-exo2">{tab.label}</span>
              </Button>
            ))}
          </div>
        </motion.div>

        {/* Overview Tab */}
        {activeTab === "overview" && (
          <motion.div 
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            {/* Key Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <Card className="glassmorphism border-blue-500/20">
                <CardContent className="p-4">
                  <div className="flex items-center">
                    <div className="p-2 bg-blue-500/20 rounded-lg mr-3">
                      <Target className="w-5 h-5 text-blue-400" />
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-white">
                        {crawler.totalPosts}
                      </div>
                      <div className="text-sm text-gray-400 font-exo2">Total Posts</div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="glassmorphism border-green-500/20">
                <CardContent className="p-4">
                  <div className="flex items-center">
                    <div className="p-2 bg-green-500/20 rounded-lg mr-3">
                      <Activity className="w-5 h-5 text-green-400" />
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-white">
                        {performance.totalEngagement.toLocaleString()}
                      </div>
                      <div className="text-sm text-gray-400 font-exo2">Total Engagement</div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="glassmorphism border-purple-500/20">
                <CardContent className="p-4">
                  <div className="flex items-center">
                    <div className="p-2 bg-purple-500/20 rounded-lg mr-3">
                      <Cpu className="w-5 h-5 text-purple-400" />
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-white">
                        {consensus.totalAgents}
                      </div>
                      <div className="text-sm text-gray-400 font-exo2">Active Agents</div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card className="glassmorphism border-yellow-500/20">
                <CardContent className="p-4">
                  <div className="flex items-center">
                    <div className="p-2 bg-yellow-500/20 rounded-lg mr-3">
                      <TrendingUp className="w-5 h-5 text-yellow-400" />
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-white">
                        {campaign.trustScore.toFixed(1)}%
                      </div>
                      <div className="text-sm text-gray-400 font-exo2">Trust Score</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Charts Row */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Sentiment Distribution */}
              <Card className="glassmorphism border-purple-500/20">
                <CardHeader>
                  <CardTitle className="flex items-center text-white font-orbitron">
                    <MessageSquare className="w-5 h-5 mr-2 text-purple-400" />
                    Sentiment Distribution
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={300}>
                    <PieChart>
                      <Pie
                        data={[
                          { name: "Positive", value: analysis.sentiment.positive, color: "#10b981" },
                          { name: "Neutral", value: analysis.sentiment.neutral, color: "#6b7280" },
                          { name: "Negative", value: analysis.sentiment.negative, color: "#ef4444" },
                        ]}
                        cx="50%"
                        cy="50%"
                        outerRadius={80}
                        dataKey="value"
                      >
                        {[
                          { name: "Positive", value: analysis.sentiment.positive, color: "#10b981" },
                          { name: "Neutral", value: analysis.sentiment.neutral, color: "#6b7280" },
                          { name: "Negative", value: analysis.sentiment.negative, color: "#ef4444" },
                        ].map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>

              {/* Platform Engagement */}
              <Card className="glassmorphism border-blue-500/20">
                <CardHeader>
                  <CardTitle className="flex items-center text-white font-orbitron">
                    <Globe className="w-5 h-5 mr-2 text-blue-400" />
                    Platform Engagement
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={300}>
                    <BarChart data={Object.entries(crawler.crawlStats).map(([platform, stats]) => ({
                      platform,
                      engagement: stats.engagement,
                      posts: stats.posts
                    }))}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                      <XAxis dataKey="platform" stroke="#9CA3AF" />
                      <YAxis stroke="#9CA3AF" />
                      <Tooltip 
                        contentStyle={{ 
                          backgroundColor: '#1F2937', 
                          border: '1px solid #374151',
                          borderRadius: '8px',
                          color: '#F9FAFB'
                        }}
                      />
                      <Bar dataKey="engagement" fill="#3b82f6" />
                    </BarChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>
            </div>

            {/* Agent Status */}
            <Card className="glassmorphism border-green-500/20">
              <CardHeader>
                <CardTitle className="flex items-center text-white font-orbitron">
                  <Cpu className="w-5 h-5 mr-2 text-green-400" />
                  Agent Status
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="text-center p-4 bg-green-500/10 rounded-lg border border-green-500/20">
                    <CheckCircle className="w-8 h-8 text-green-400 mx-auto mb-2" />
                    <div className="text-2xl font-bold text-green-400">
                      {consensus.activeAgents}
                    </div>
                    <div className="text-sm text-green-400 font-exo2">Active Agents</div>
                  </div>
                  <div className="text-center p-4 bg-yellow-500/10 rounded-lg border border-yellow-500/20">
                    <Clock className="w-8 h-8 text-yellow-400 mx-auto mb-2" />
                    <div className="text-2xl font-bold text-yellow-400">
                      {consensus.totalAgents - consensus.activeAgents}
                    </div>
                    <div className="text-sm text-yellow-400 font-exo2">Idle Agents</div>
                  </div>
                  <div className="text-center p-4 bg-red-500/10 rounded-lg border border-red-500/20">
                    <XCircle className="w-8 h-8 text-red-400 mx-auto mb-2" />
                    <div className="text-2xl font-bold text-red-400">
                      {crawler.agentStatus.filter((a: any) => a.status === 'OFFLINE').length}
                    </div>
                    <div className="text-sm text-red-400 font-exo2">Offline Agents</div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* Crawler Tab */}
        {activeTab === "crawler" && (
          <motion.div 
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <Card className="glassmorphism border-blue-500/20">
              <CardHeader>
                <CardTitle className="flex items-center text-white font-orbitron">
                  <Globe className="w-5 h-5 mr-2 text-blue-400" />
                  Crawler Performance
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div className="text-center p-4 bg-blue-500/10 rounded-lg border border-blue-500/20">
                    <div className="text-2xl font-bold text-blue-400">
                      {crawler.totalPosts}
                    </div>
                    <div className="text-sm text-blue-400 font-exo2">Total Posts Crawled</div>
                  </div>
                  <div className="text-center p-4 bg-green-500/10 rounded-lg border border-green-500/20">
                    <div className="text-2xl font-bold text-green-400">
                      {performance.averageResponseTime.toFixed(1)}s
                    </div>
                    <div className="text-sm text-green-400 font-exo2">Avg Response Time</div>
                  </div>
                  <div className="text-center p-4 bg-purple-500/10 rounded-lg border border-purple-500/20">
                    <div className="text-2xl font-bold text-purple-400">
                      {crawler.platforms.length}
                    </div>
                    <div className="text-sm text-purple-400 font-exo2">Platforms Monitored</div>
                  </div>
                </div>

                {/* Platform Breakdown */}
                <div className="space-y-4">
                  <h4 className="font-semibold text-white font-orbitron">Platform Breakdown</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {Object.entries(crawler.crawlStats).map(([platform, stats]) => (
                      <div key={platform} className="p-4 border border-gray-600/50 rounded-lg bg-gray-800/30">
                        <div className="flex items-center justify-between mb-2">
                          <span className="font-medium text-white capitalize font-exo2">
                            {platform}
                          </span>
                          <Badge variant="outline" className="border-blue-500/30 text-blue-400 bg-blue-500/10">
                            {stats.posts} posts
                          </Badge>
                        </div>
                        <div className="space-y-2">
                          <div className="flex justify-between text-sm">
                            <span className="text-gray-400">Engagement:</span>
                            <span className="font-medium text-white">{stats.engagement.toLocaleString()}</span>
                          </div>
                          <div className="w-full bg-gray-700 rounded-full h-2">
                            <div
                              className="bg-blue-500 h-2 rounded-full"
                              style={{
                                width: `${Math.min((stats.engagement / performance.totalEngagement) * 100, 100)}%`
                              }}
                            />
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* Analysis Tab */}
        {activeTab === "analysis" && (
          <motion.div 
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <Card className="glassmorphism border-green-500/20">
              <CardHeader>
                <CardTitle className="flex items-center text-white font-orbitron">
                  <TrendingUp className="w-5 h-5 mr-2 text-green-400" />
                  Sentiment Analysis
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div className="text-center p-4 bg-green-500/10 rounded-lg border border-green-500/20">
                    <div className="text-2xl font-bold text-green-400">
                      {analysis.sentiment.positive}
                    </div>
                    <div className="text-sm text-green-400 font-exo2">Positive Posts</div>
                  </div>
                  <div className="text-center p-4 bg-gray-500/10 rounded-lg border border-gray-500/20">
                    <div className="text-2xl font-bold text-gray-400">
                      {analysis.sentiment.neutral}
                    </div>
                    <div className="text-sm text-gray-400 font-exo2">Neutral Posts</div>
                  </div>
                  <div className="text-center p-4 bg-red-500/10 rounded-lg border border-red-500/20">
                    <div className="text-2xl font-bold text-red-400">
                      {analysis.sentiment.negative}
                    </div>
                    <div className="text-sm text-red-400 font-exo2">Negative Posts</div>
                  </div>
                </div>

                {/* Trending Topics */}
                <div className="space-y-4">
                  <h4 className="font-semibold text-white font-orbitron">Trending Topics</h4>
                  <div className="flex flex-wrap gap-2">
                    {analysis.trends.keywords.slice(0, 10).map((keyword, index) => (
                      <Badge key={index} variant="outline" className="text-sm border-purple-500/30 text-purple-400 bg-purple-500/10">
                        {keyword}
                      </Badge>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* Consensus Tab */}
        {activeTab === "consensus" && (
          <motion.div 
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <Card className="glassmorphism border-purple-500/20">
              <CardHeader>
                <CardTitle className="flex items-center text-white font-orbitron">
                  <Cpu className="w-5 h-5 mr-2 text-purple-400" />
                  Consensus Verification
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div className="text-center p-4 bg-green-500/10 rounded-lg border border-green-500/20">
                    <div className="text-2xl font-bold text-green-400">
                      {consensus.consensusScore.toFixed(1)}%
                    </div>
                    <div className="text-sm text-green-400 font-exo2">Consensus Score</div>
                  </div>
                  <div className="text-center p-4 bg-blue-500/10 rounded-lg border border-blue-500/20">
                    <div className="text-2xl font-bold text-blue-400">
                      {consensus.totalAgents}
                    </div>
                    <div className="text-sm text-blue-400 font-exo2">Total Agents</div>
                  </div>
                  <div className="text-center p-4 bg-purple-500/10 rounded-lg border border-purple-500/20">
                    <div className="text-2xl font-bold text-purple-400">
                      {consensus.activeAgents}
                    </div>
                    <div className="text-sm text-purple-400 font-exo2">Active Agents</div>
                  </div>
                </div>

                {/* Agent Performance */}
                <div className="space-y-4">
                  <h4 className="font-semibold text-white font-orbitron">Agent Performance</h4>
                  <div className="space-y-2">
                    {consensus.agentPerformance.slice(0, 5).map((agent: any, index: number) => (
                      <div key={index} className="flex items-center justify-between p-3 border border-gray-600/50 rounded-lg bg-gray-800/30">
                        <div className="flex items-center space-x-3">
                          <div className={`w-3 h-3 rounded-full ${
                            agent.status === 'ACTIVE' ? 'bg-green-500' : 
                            agent.status === 'IDLE' ? 'bg-yellow-500' : 'bg-red-500'
                          }`} />
                          <span className="font-medium text-white font-exo2">{agent.name}</span>
                        </div>
                        <div className="text-sm text-gray-400 font-exo2">
                          {agent.accuracy?.toFixed(1)}% accuracy
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* Timeline Tab */}
        {activeTab === "timeline" && (
          <motion.div 
            className="space-y-6"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <Card className="glassmorphism border-blue-500/20">
              <CardHeader>
                <CardTitle className="flex items-center text-white font-orbitron">
                  <Activity className="w-5 h-5 mr-2 text-blue-400" />
                  Activity Timeline
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={400}>
                  <AreaChart data={timeline.posts.slice(-30)}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                    <XAxis dataKey="date" stroke="#9CA3AF" />
                    <YAxis stroke="#9CA3AF" />
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: '#1F2937', 
                        border: '1px solid #374151',
                        borderRadius: '8px',
                        color: '#F9FAFB'
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="posts"
                      stackId="1"
                      stroke="#3b82f6"
                      fill="#3b82f6"
                      fillOpacity={0.6}
                    />
                    <Area
                      type="monotone"
                      dataKey="engagement"
                      stackId="2"
                      stroke="#10b981"
                      fill="#10b981"
                      fillOpacity={0.6}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  );
}
