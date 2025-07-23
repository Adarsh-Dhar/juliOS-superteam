"use client";

import React, { useEffect, useState } from "react";
import {
  Card,
  CardHeader,
  CardTitle,
  CardDescription,
  CardContent,
} from "@/components/ui/card";
import { ChartContainer } from "@/components/ui/chart";
import { useToast } from "@/hooks/use-toast";
import {
  LineChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Line,
} from "recharts";

function fetcher(url: string) {
  return fetch(url).then((res) => {
    if (!res.ok) throw new Error("Failed to fetch");
    return res.json();
  });
}

export default function AnalyticsPage() {
  const { toast } = useToast();

  // State for each analytics section
  const [campaign, setCampaign] = useState<any>(null);
  const [trustScore, setTrustScore] = useState<any>(null);
  const [swarmStats, setSwarmStats] = useState<any>(null);
  const [timeline, setTimeline] = useState<any[]>([]);
  const [fraudPatterns, setFraudPatterns] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    Promise.all([
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
    ]).then(
      ([c, t, s, tl, fp]) => {
        setCampaign(c);
        setTrustScore(t);
        setSwarmStats(s);
        setTimeline(tl);
        setFraudPatterns(fp.patterns || []);
        setLoading(false);
      }
    );
    // eslint-disable-next-line
  }, []);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Analytics Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        {/* Campaign Summary */}
        <Card>
          <CardHeader>
            <CardTitle>Campaigns</CardTitle>
            <CardDescription>Overview of campaigns and engagement</CardDescription>
          </CardHeader>
          <CardContent>
            {campaign ? (
              <div className="space-y-2">
                <div className="text-lg font-semibold">{campaign.totalCampaigns} campaigns</div>
                <div className="text-muted-foreground">{campaign.totalPosts} posts</div>
                <div className="text-muted-foreground">Engagement: {campaign.engagement}%</div>
              </div>
            ) : (
              <div className="animate-pulse h-16 bg-muted rounded" />
            )}
          </CardContent>
        </Card>
        {/* Trust Score */}
        <Card>
          <CardHeader>
            <CardTitle>Trust Score</CardTitle>
            <CardDescription>Average confidence of authentic verifications</CardDescription>
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
            <CardTitle>Swarm Stats</CardTitle>
            <CardDescription>Network health and agent activity</CardDescription>
          </CardHeader>
          <CardContent>
            {swarmStats ? (
              <div className="space-y-2">
                <div className="font-semibold">Active Agents: {swarmStats.activeAgents}</div>
                <div className="text-muted-foreground">Verified Today: {swarmStats.verifiedToday}</div>
                <div className="text-muted-foreground">Network Health: {swarmStats.networkHealth}%</div>
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
            <CardTitle>Verification Timeline</CardTitle>
            <CardDescription>Authentic, suspicious, and fake verifications over time</CardDescription>
          </CardHeader>
          <CardContent>
            {timeline && timeline.length > 0 ? (
              <ChartContainer
                config={{
                  authentic: { label: "Authentic", color: "#22c55e" },
                  suspicious: { label: "Suspicious", color: "#eab308" },
                  fake: { label: "Fake", color: "#ef4444" },
                }}
                className="h-72"
              >
                <LineChart data={timeline} margin={{ top: 16, right: 16, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="time" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="authentic" stroke="#22c55e" strokeWidth={2} />
                  <Line type="monotone" dataKey="suspicious" stroke="#eab308" strokeWidth={2} />
                  <Line type="monotone" dataKey="fake" stroke="#ef4444" strokeWidth={2} />
                </LineChart>
              </ChartContainer>
            ) : (
              <div className="animate-pulse h-72 bg-muted rounded" />
            )}
          </CardContent>
        </Card>
      </div>
      {/* Fraud Patterns */}
      <div>
        <Card>
          <CardHeader>
            <CardTitle>Fraud Patterns</CardTitle>
            <CardDescription>Detected fraud types and their severity</CardDescription>
          </CardHeader>
          <CardContent>
            {fraudPatterns && fraudPatterns.length > 0 ? (
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
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
