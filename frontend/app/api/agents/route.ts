import { NextRequest, NextResponse } from 'next/server';
// import { prisma } from '@/lib/prisma';

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
  const { type, name, status } = data;
  if (!type || !name) {
    return NextResponse.json({ error: 'Missing type or name' }, { status: 400 });
  }
  // Proxy the request to the Julia backend
  try {
    const juliaRes = await fetch(JULIA_API_BASE, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        name,
        type,
        status: status || 'ACTIVE',
      }),
    });
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to create agent in Julia backend', details: error?.toString() }, { status: 500 });
  }
} 