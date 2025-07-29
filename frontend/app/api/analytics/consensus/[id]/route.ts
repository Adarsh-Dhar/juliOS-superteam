import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const JULIA_API_BASE = process.env.JULIA_API_BASE || 'http://localhost:8055/api/v1';

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const campaignId = params.id;
    
    // Get campaign verification data
    const verifications = await prisma.verification.findMany({
      where: { 
        post: { campaignId }
      },
      include: {
        post: true,
        votes: true
      }
    });

    // Fetch consensus data from Julia
    const consensusData = await fetchJuliaConsensusData(campaignId);

    const analytics = {
      // Consensus Overview
      consensus: {
        totalVerifications: verifications.length,
        authenticPosts: verifications.filter(v => v.status === 'AUTHENTIC').length,
        fakePosts: verifications.filter(v => v.status === 'FAKE').length,
        pendingPosts: verifications.filter(v => v.status === 'PENDING').length,
        consensusScore: consensusData.consensusScore || 0,
        averageConfidence: consensusData.averageConfidence || 0
      },

      // Agent Performance
      agents: {
        totalAgents: consensusData.totalAgents || 0,
        activeAgents: consensusData.activeAgents || 0,
        agentPerformance: consensusData.agentPerformance || [],
        agentStatus: consensusData.agentStatus || [],
        responseTimes: consensusData.responseTimes || []
      },

      // Verification Results
      verification: {
        results: verifications.map(verification => ({
          id: verification.id,
          postId: verification.post?.id || '',
          status: verification.status,
          confidence: verification.confidence,
          votes: verification.votes.length,
          createdAt: verification.createdAt
        })),
        
        breakdown: {
          authentic: verifications.filter(v => v.status === 'AUTHENTIC').length,
          fake: verifications.filter(v => v.status === 'FAKE').length,
          pending: verifications.filter(v => v.status === 'PENDING').length
        },

        confidenceDistribution: {
          high: verifications.filter(v => v.confidence >= 0.8).length,
          medium: verifications.filter(v => v.confidence >= 0.5 && v.confidence < 0.8).length,
          low: verifications.filter(v => v.confidence < 0.5).length
        }
      },

      // Julia Consensus Data
      juliaData: {
        consensusVerification: consensusData.consensusVerification || {},
        agentConsensus: consensusData.agentConsensus || [],
        verificationResults: consensusData.verificationResults || [],
        trustMetrics: consensusData.trustMetrics || {}
      },

      // Timeline Data
      timeline: {
        verifications: verifications.map(v => ({
          date: v.createdAt,
          status: v.status,
          confidence: v.confidence
        })),
        consensusTrend: consensusData.consensusTrend || []
      },

      // Trust Metrics
      trust: {
        overallTrustScore: consensusData.overallTrustScore || 0,
        platformTrustScores: consensusData.platformTrustScores || {},
        trustTrend: consensusData.trustTrend || [],
        riskAssessment: consensusData.riskAssessment || {}
      }
    };

    return NextResponse.json(analytics);
  } catch (error) {
    console.error('Error fetching consensus analytics:', error);
    return NextResponse.json(
      { error: 'Failed to fetch consensus analytics' },
      { status: 500 }
    );
  }
}

async function fetchJuliaConsensusData(campaignId: string) {
  try {
    const response = await fetch(`${JULIA_API_BASE}/consensus/campaign/${campaignId}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    
    if (!response.ok) {
      console.warn('Failed to fetch consensus data from Julia');
      return {};
    }
    
    return await response.json();
  } catch (error) {
    console.warn('Error fetching consensus data:', error);
    return {};
  }
} 