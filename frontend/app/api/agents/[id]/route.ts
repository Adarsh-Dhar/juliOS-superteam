import { NextRequest, NextResponse } from 'next/server';

export const dynamic = "force-dynamic";

const JULIA_API_BASE = 'http://localhost:8052/api/v1/agents';

export async function GET(_req: NextRequest, context: { params: { id: string } }) {
  const { id } = context.params;
  try {
    const juliaRes = await fetch(`${JULIA_API_BASE}/${id}`);
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch agent from Julia backend', details: error?.toString() }, { status: 500 });
  }
}

export async function PUT(req: NextRequest, context: { params: { id: string } }) {
  const { id } = context.params;
  const body = await req.json();
  // Julia expects { state: ... } for status update
  const payload = { state: body.state || body.status };
  console.log("PUT /api/agents/[id] payload:", payload); // Debug log
  try {
    const juliaRes = await fetch(`${JULIA_API_BASE}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const juliaData = await juliaRes.json();
    return NextResponse.json(juliaData, { status: juliaRes.status });
  } catch (error) {
    return NextResponse.json({ error: 'Failed to update agent in Julia backend', details: error?.toString() }, { status: 500 });
  }
}

export async function DELETE(_req: NextRequest, context: { params: { id: string } }) {
  const { id } = context.params;
  try {
    const juliaRes = await fetch(`${JULIA_API_BASE}/${id}`, { method: 'DELETE' });
    if (juliaRes.status === 204) {
      return NextResponse.json({ success: true });
    } else {
      const error = await juliaRes.json();
      return NextResponse.json(error, { status: juliaRes.status });
    }
  } catch (error) {
    return NextResponse.json({ error: 'Failed to delete agent in Julia backend', details: error?.toString() }, { status: 500 });
  }
} 