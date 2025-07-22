import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  // For demo, just echo back
  return NextResponse.json({ ...data, verificationId: params.id, voted: true });
} 