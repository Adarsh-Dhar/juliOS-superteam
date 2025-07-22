import { NextRequest, NextResponse } from 'next/server';

const verifications = [
  { id: '1', status: 'pending', user: 'user1' },
  { id: '2', status: 'approved', user: 'user2' },
];

export async function GET() {
  return NextResponse.json(verifications);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: String(Date.now()) });
} 