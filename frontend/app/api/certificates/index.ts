import { NextRequest, NextResponse } from 'next/server';

const certificates = [
  { id: '1', name: 'Certificate 1', owner: 'user1' },
  { id: '2', name: 'Certificate 2', owner: 'user2' },
];

export async function GET() {
  return NextResponse.json(certificates);
}

export async function POST(req: NextRequest) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: String(Date.now()) });
} 