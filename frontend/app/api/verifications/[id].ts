import { NextRequest, NextResponse } from 'next/server';

const verifications = [
  { id: '1', status: 'pending', user: 'user1' },
  { id: '2', status: 'approved', user: 'user2' },
];

export async function GET(req: NextRequest, { params }: { params: { id: string } }) {
  const verification = verifications.find(v => v.id === params.id);
  if (!verification) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json(verification);
}

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const data = await req.json();
  return NextResponse.json({ ...data, id: params.id });
}

export async function DELETE(req: NextRequest, { params }: { params: { id: string } }) {
  return NextResponse.json({ success: true, id: params.id });
} 