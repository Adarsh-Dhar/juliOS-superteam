import { NextRequest, NextResponse } from 'next/server';

export const dynamic = "force-dynamic";

export async function POST(req: NextRequest) {
  const { action } = await req.json();
  try {
    // Forward the action to the Julia HTTP server
    const juliaRes = await fetch("http://localhost:8000/control", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action }),
    });
    const data = await juliaRes.json();
    return NextResponse.json(data);
  } catch (error) {
    return NextResponse.json({ error: 'Failed to trigger Julia agent' }, { status: 500 });
  }
} 