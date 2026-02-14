-- Create Profiles Table (Linked to Auth Users)
create table profiles (
  id uuid references auth.users not null primary key,
  full_name text,
  phone_number text,
  email text,
  updated_at timestamp with time zone,
  constraint unique_email unique (email)
);

-- Triggers to handle user creation automatically if you want (optional but recommended)
-- But for now we handle it in the app via AuthProvider

-- Create Medicines Table
create table medicines (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  medicine_name text not null,
  batch_number text not null,
  manufactured_date timestamp with time zone not null,
  expiry_date timestamp with time zone not null,
  use_case text,
  disposed boolean default false,
  created_at timestamp with time zone default now()
);

-- Create History Table
create table history (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  medicine_id text, -- Loose reference to allow logs even if medicine is deleted
  action text not null,
  details text,
  timestamp timestamp with time zone default now()
);

-- Enable Row Level Security (RLS)
alter table profiles enable row level security;
alter table medicines enable row level security;
alter table history enable row level security;

-- Policies for Profiles
create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);

create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

create policy "Users can insert own profile" on profiles
  for insert with check (auth.uid() = id);

-- Policies for Medicines
create policy "Users can view own medicines" on medicines
  for select using (auth.uid() = user_id);

create policy "Users can insert own medicines" on medicines
  for insert with check (auth.uid() = user_id);

create policy "Users can update own medicines" on medicines
  for update using (auth.uid() = user_id);

create policy "Users can delete own medicines" on medicines
  for delete using (auth.uid() = user_id);

-- Policies for History
create policy "Users can view own history" on history
  for select using (auth.uid() = user_id);

create policy "Users can insert own history" on history
  for insert with check (auth.uid() = user_id);
