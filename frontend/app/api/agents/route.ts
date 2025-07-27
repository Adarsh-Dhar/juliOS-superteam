import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export const dynamic = "force-dynamic";

const JULIA_API_BASE = 'http://localhost:8052/api/v1/agents';

export async function GET() {
  // Fetch agents from Julia backend
  try {
    const juliaRes = await fetch(JULIA_API_BASE);
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch agents from Julia backend', details: error?.toString() }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  const { name, type, status, campaignId, agentConfig } = data;
  
  console.log('Received agent creation request:', { name, type, status, campaignId, agentConfig });
  
  if (!type || !name) {
    return NextResponse.json({ error: 'Missing type or name' }, { status: 400 });
  }

  try {
    // Check if Julia backend is available
    let juliaAgent = null;
    try {
      // First, create agent in Julia backend
      const juliaAgentData = {
        name,
        type,
        status: status || 'ACTIVE',
        abilities: getAbilitiesForType(type),
        parameters: agentConfig || {},
        llm_config: {
          provider: "openai",
          model: "gpt-4",
          temperature: 0.1
        },
        memory_config: {
          type: "ordered_dict",
          max_size: 1000
        },
        queue_config: {
          type: "priority_queue"
        }
      };

      console.log('Creating agent in Julia backend:', juliaAgentData);

      const juliaRes = await fetch(JULIA_API_BASE, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(juliaAgentData),
      });

      if (juliaRes.ok) {
        juliaAgent = await juliaRes.json();
        console.log('Julia agent created:', juliaAgent);
      } else {
        const errorText = await juliaRes.text();
        console.warn('Julia backend error (will create in database only):', errorText);
      }
    } catch (juliaError) {
      console.warn('Julia backend not available (will create in database only):', juliaError);
    }

    // Create agent record in our database
    console.log('Creating database agent record...');
    const agentId = juliaAgent?.id || `agent-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const dbAgent = await prisma.agent.create({
      data: {
        id: agentId,
        type: mapJuliaTypeToDbType(type) as any, // Cast to any to handle enum conversion
        name: name,
        status: status || 'ACTIVE',
        location: juliaAgent ? 'julia-backend' : 'database-only',
        version: '1.0.0',
        // Store campaign-specific configuration
        metadata: {
          campaignId,
          agentConfig,
          juliaAgentId: juliaAgent?.id || null,
          juliaBackendAvailable: !!juliaAgent
        }
      },
    });

    console.log('Database agent created:', dbAgent);

    return NextResponse.json({
      id: dbAgent.id,
      name: dbAgent.name,
      type: dbAgent.type,
      status: dbAgent.status,
      dbId: dbAgent.id,
      campaignId,
      agentConfig,
      juliaBackendAvailable: !!juliaAgent
    }, { status: 201 });

  } catch (error) {
    console.error('Error creating agent:', error);
    console.error('Error details:', {
      message: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined,
      name: error instanceof Error ? error.name : undefined
    });
    return NextResponse.json({ 
      error: 'Failed to create agent', 
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 });
  }
}

// Helper function to map Julia agent types to database types
function mapJuliaTypeToDbType(juliaType: string): string {
  const typeMap: { [key: string]: string } = {
    'CRAWLER': 'CRAWLER',
    'SENTIMENT_ANALYZER': 'SENTIMENT_ANALYZER',
    'TREND_ANALYZER': 'TREND_ANALYZER',
    'CONSENSUS': 'CONSENSUS',
    'VALIDATOR': 'VALIDATOR',
    'ANALYTICS': 'ANALYTICS',
    'REPORTER': 'REPORTER'
  };
  
  return typeMap[juliaType] || 'CRAWLER';
}

// Helper function to get abilities based on agent type
function getAbilitiesForType(type: string): string[] {
  const abilitiesMap: { [key: string]: string[] } = {
    'CRAWLER': ['web_scraping', 'content_extraction', 'platform_api'],
    'SENTIMENT_ANALYZER': ['sentiment_analysis', 'emotion_detection', 'text_processing'],
    'TREND_ANALYZER': ['trend_analysis', 'pattern_recognition', 'data_aggregation'],
    'CONSENSUS': ['content_validation', 'authenticity_scoring', 'voting_mechanism'],
    'VALIDATOR': ['content_verification', 'fraud_detection', 'trust_scoring'],
    'ANALYTICS': ['data_analysis', 'reporting', 'insights_generation'],
    'REPORTER': ['report_generation', 'alert_system', 'notification']
  };
  
  return abilitiesMap[type] || ['general_purpose'];
} 