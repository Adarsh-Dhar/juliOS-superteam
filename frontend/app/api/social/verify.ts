import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const data = await req.json();
  // For demo, just echo back
  return NextResponse.json({ ...data, verified: true });
} 