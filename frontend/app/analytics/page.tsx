"use client";

import React, { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
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
} from "lucide-react";

function fetcher(url: string) {
  return fetch(url).then((res) => {
    if (!res.ok) throw new Error("Failed to fetch");
    return res.json();
  });
}

export default function AnalyticsPage() {
  const { toast } = useToast();
  const searchParams = useSearchParams();
  const campaignId = searchParams.get('campaign');

  // State for each analytics section
  const [campaign, setCampaign] = useState<any>(null);
  const [trustScore, setTrustScore] = useState<any>(null);
  const [swarmStats, setSwarmStats] = useState<any>(null);
  const [timeline, setTimeline] = useState<any[]>([]);
  const [fraudPatterns, setFraudPatterns] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [campaignDetails, setCampaignDetails] = useState<any>(null);

  useEffect(() => {
    setLoading(true);
    
    const fetchData = async () => {
      try {
        // If campaign ID is provided, fetch campaign-specific data
        if (campaignId) {
          const [campaignData, campaignDetailsData] = await Promise.all([
            fetcher(`/api/analytics/campaign/${campaignId}`).catch((e) => {
              toast({ title: "Error", description: "Failed to load campaign analytics" });
              return null;
            }),
            fetcher(`/api/campaigns/${campaignId}`).catch((e) => {
              toast({ title: "Error", description: "Failed to load campaign details" });
              return null;
            }),
          ]);
          
          setCampaign(campaignData);
          setCampaignDetails(campaignDetailsData);
        } else {
          // Fetch general analytics data
          const [c, t, s, tl, fp] = await Promise.all([
            fetcher("/api/analytics/campaign").catch((e) => {
              toast({ title: "Error", description: "Failed to load campaign summary" });
              return null;
            }),
            fetcher("/api/analytics/trust-score").catch((e) => {
              toast({ title: "Error", description: "Failed to load trust score" });
              return null;
            }),
            fetcher("/api/analytics/swarm-stats").catch((e) => {
              toast({ title: "Error", description: "Failed to load swarm stats" });
              return null;
            }),
            fetcher("/api/analytics/timeline").catch((e) => {
              toast({ title: "Error", description: "Failed to load timeline" });
              return [];
            }),
            fetcher("/api/analytics/fraud-patterns").catch((e) => {
              toast({ title: "Error", description: "Failed to load fraud patterns" });
              return { patterns: [] };
            }),
          ]);
          
          setCampaign(c);
          setTrustScore(t);
          setSwarmStats(s);
          setTimeline(tl);
          setFraudPatterns(fp.patterns || []);
        }
      } catch (error) {
        console.error('Error fetching analytics data:', error);
        toast({ title: "Error", description: "Failed to load analytics data" });
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [campaignId, toast]);

  const handleBackToCampaigns = () => {
    window.history.back();
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4">
            {campaignId && (
              <Button
                variant="outline"
                onClick={handleBackToCampaigns}
                className="flex items-center gap-2"
              >
                <ArrowLeft className="w-4 h-4" />
                Back to Campaigns
              </Button>
            )}
            <div>
              <h1 className="text-3xl font-bold">
                {campaignId ? 'Campaign Analytics' : 'Analytics Dashboard'}
              </h1>
              <p className="text-muted-foreground">
                {campaignId 
                  ? `Analytics for campaign: ${campaignDetails?.name || 'Loading...'}`
                  : 'Overview of all campaigns and engagement'
                }
              </p>
            </div>
          </div>
        </div>

        {/* Campaign Details Banner */}
        {campaignId && campaignDetails && (
          <Card className="mb-6 border-blue-200 bg-blue-50">
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="p-2 bg-blue-100 rounded-lg">
                    <Target className="w-5 h-5 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-blue-900">{campaignDetails.name}</h3>
                    <div className="flex items-center gap-4 text-sm text-blue-700">
                      <span className="flex items-center gap-1">
                        <Hash className="w-3 h-3" />
                        #{campaignDetails.hashtag}
                      </span>
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        Started {new Date(campaignDetails.startDate).toLocaleDateString()}
                      </span>
                      <span className="flex items-center gap-1">
                        <Cpu className="w-3 h-3" />
                        {campaignDetails.metadata?.totalAgents || 0} Agents
                      </span>
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-blue-900">
                    {campaignDetails.trustScore?.toFixed(1) || 0}%
                  </div>
                  <div className="text-sm text-blue-700">Trust Score</div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}
      </div>

      {/* Analytics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        {/* Campaign Summary */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Target className="w-5 h-5" />
              {campaignId ? 'Campaign Stats' : 'Campaigns'}
            </CardTitle>
            <CardDescription>
              {campaignId ? 'Performance metrics for this campaign' : 'Overview of campaigns and engagement'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {campaign ? (
              <div className="space-y-2">
                {campaignId ? (
                  <>
                    <div className="text-lg font-semibold">{campaign.totalPosts || 0} posts</div>
                    <div className="text-muted-foreground">Engagement: {campaign.engagement || 0}%</div>
                    <div className="text-muted-foreground">Reach: {campaign.reach || 0}</div>
                  </>
                ) : (
                  <>
                    <div className="text-lg font-semibold">{campaign.totalCampaigns} campaigns</div>
                    <div className="text-muted-foreground">{campaign.totalPosts} posts</div>
                    <div className="text-muted-foreground">Engagement: {campaign.engagement}%</div>
                  </>
                )}
              </div>
            ) : (
              <div className="animate-pulse h-16 bg-muted rounded" />
            )}
          </CardContent>
        </Card>

        {/* Trust Score */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5" />
              Trust Score
            </CardTitle>
            <CardDescription>
              {campaignId ? 'Campaign confidence level' : 'Average confidence of authentic verifications'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {trustScore ? (
              <div className="text-3xl font-bold">{trustScore.score}</div>
            ) : (
              <div className="animate-pulse h-10 bg-muted rounded" />
            )}
          </CardContent>
        </Card>

        {/* Swarm Stats */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Activity className="w-5 h-5" />
              {campaignId ? 'Agent Activity' : 'Swarm Stats'}
            </CardTitle>
            <CardDescription>
              {campaignId ? 'Campaign agent performance' : 'Network health and agent activity'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            {swarmStats ? (
              <div className="space-y-2">
                {campaignId ? (
                  <>
                    <div className="font-semibold">Active Agents: {swarmStats.activeAgents || 0}</div>
                    <div className="text-muted-foreground">Posts Analyzed: {swarmStats.postsAnalyzed || 0}</div>
                    <div className="text-muted-foreground">Success Rate: {swarmStats.successRate || 0}%</div>
                  </>
                ) : (
                  <>
                    <div className="font-semibold">Active Agents: {swarmStats.activeAgents}</div>
                    <div className="text-muted-foreground">Verified Today: {swarmStats.verifiedToday}</div>
                    <div className="text-muted-foreground">Network Health: {swarmStats.networkHealth}%</div>
                  </>
                )}
              </div>
            ) : (
              <div className="animate-pulse h-16 bg-muted rounded" />
            )}
          </CardContent>
        </Card>
      </div>

      {/* Timeline Chart */}
      <div className="mb-6">
        <Card>
          <CardHeader>
            <CardTitle>
              {campaignId ? 'Campaign Timeline' : 'Verification Timeline'}
            </CardTitle>
            <CardDescription>
              {campaignId 
                ? 'Campaign performance and engagement over time'
                : 'Authentic, suspicious, and fake verifications over time'
              }
            </CardDescription>
          </CardHeader>
          <CardContent>
            {timeline && timeline.length > 0 ? (
              <ChartContainer
                config={{
                  authentic: { label: "Authentic", color: "#22c55e" },
                  suspicious: { label: "Suspicious", color: "#eab308" },
                  fake: { label: "Fake", color: "#ef4444" },
                  engagement: { label: "Engagement", color: "#3b82f6" },
                  posts: { label: "Posts", color: "#8b5cf6" },
                }}
                className="h-72"
              >
                <LineChart data={timeline} margin={{ top: 16, right: 16, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="time" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  {campaignId ? (
                    <>
                      <Line type="monotone" dataKey="posts" stroke="#8b5cf6" strokeWidth={2} />
                      <Line type="monotone" dataKey="engagement" stroke="#3b82f6" strokeWidth={2} />
                    </>
                  ) : (
                    <>
                      <Line type="monotone" dataKey="authentic" stroke="#22c55e" strokeWidth={2} />
                      <Line type="monotone" dataKey="suspicious" stroke="#eab308" strokeWidth={2} />
                      <Line type="monotone" dataKey="fake" stroke="#ef4444" strokeWidth={2} />
                    </>
                  )}
                </LineChart>
              </ChartContainer>
            ) : (
              <div className="animate-pulse h-72 bg-muted rounded" />
            )}
          </CardContent>
        </Card>
      </div>

      {/* Fraud Patterns or Campaign Insights */}
      <div>
        <Card>
          <CardHeader>
            <CardTitle>
              {campaignId ? 'Campaign Insights' : 'Fraud Patterns'}
            </CardTitle>
            <CardDescription>
              {campaignId 
                ? 'Key insights and patterns from this campaign'
                : 'Detected fraud types and their severity'
              }
            </CardDescription>
          </CardHeader>
          <CardContent>
            {campaignId ? (
              // Campaign-specific insights
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="font-semibold mb-3">Platform Performance</h4>
                  <div className="space-y-2">
                    {campaignDetails?.metadata?.platforms?.map((platform: string) => (
                      <div key={platform} className="flex items-center justify-between p-2 bg-slate-50 rounded">
                        <span className="flex items-center gap-2">
                          <Globe className="w-4 h-4" />
                          {platform}
                        </span>
                        <Badge variant="secondary">Active</Badge>
                      </div>
                    ))}
                  </div>
                </div>
                <div>
                  <h4 className="font-semibold mb-3">Agent Status</h4>
                  <div className="space-y-2">
                    <div className="flex items-center justify-between p-2 bg-green-50 rounded">
                      <span className="flex items-center gap-2">
                        <CheckCircle className="w-4 h-4 text-green-600" />
                        Crawler Agents
                      </span>
                      <span className="text-sm font-medium">{campaignDetails?.metadata?.agentDetails?.crawlers?.length || 0}</span>
                    </div>
                    <div className="flex items-center justify-between p-2 bg-blue-50 rounded">
                      <span className="flex items-center gap-2">
                        <Cpu className="w-4 h-4 text-blue-600" />
                        Analyzer Agents
                      </span>
                      <span className="text-sm font-medium">{campaignDetails?.metadata?.agentDetails?.fixedAnalyzers?.length || 0}</span>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              // General fraud patterns
              fraudPatterns && fraudPatterns.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="min-w-full text-sm">
                    <thead>
                      <tr className="text-muted-foreground">
                        <th className="px-2 py-1 text-left">Type</th>
                        <th className="px-2 py-1 text-left">Count</th>
                        <th className="px-2 py-1 text-left">Confidence</th>
                        <th className="px-2 py-1 text-left">Severity</th>
                        <th className="px-2 py-1 text-left">Related</th>
                      </tr>
                    </thead>
                    <tbody>
                      {fraudPatterns.map((pattern: any) => (
                        <tr key={pattern.id} className="border-b last:border-0">
                          <td className="px-2 py-1 font-medium">{pattern.type}</td>
                          <td className="px-2 py-1">{pattern.count}</td>
                          <td className="px-2 py-1">{pattern.confidence.toFixed(2)}</td>
                          <td className="px-2 py-1">
                            <span className={`px-2 py-0.5 rounded text-xs font-semibold ${
                              pattern.severity === "high"
                                ? "bg-red-100 text-red-700"
                                : pattern.severity === "medium"
                                ? "bg-yellow-100 text-yellow-700"
                                : "bg-green-100 text-green-700"
                            }`}>
                              {pattern.severity}
                            </span>
                          </td>
                          <td className="px-2 py-1">
                            {pattern.relatedPatterns.join(", ")}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="animate-pulse h-16 bg-muted rounded" />
              )
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
