/*
  # VaraHub Database Schema
  
  ## Overview
  Complete database schema for VaraHub vehicle rental and buy/sell platform.
  
  ## New Tables
  
  ### 1. users
  - `id` (uuid, primary key) - Auto-generated user ID
  - `email` (text, unique) - User email
  - `phone` (text, unique) - User phone number
  - `full_name` (text) - User's full name
  - `profile_photo` (text) - Profile photo URL
  - `kyc_status` (text) - Verification status: 'pending', 'approved', 'rejected'
  - `nid_card_url` (text) - National ID card photo URL
  - `license_url` (text) - Driving license photo URL
  - `nid_number` (text) - Extracted NID number
  - `license_number` (text) - Extracted license number
  - `wallet_balance` (decimal) - User's wallet balance
  - `rating` (decimal) - Average user rating (0-5)
  - `total_reviews` (integer) - Total number of reviews
  - `language_preference` (text) - 'en' or 'bn'
  - `dark_mode` (boolean) - Dark mode preference
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp
  
  ### 2. vehicles
  - `id` (uuid, primary key) - Vehicle ID
  - `owner_id` (uuid, foreign key) - References users.id
  - `type` (text) - 'car' or 'bike'
  - `listing_type` (text) - 'rent' or 'sell'
  - `brand` (text) - Vehicle brand
  - `model` (text) - Vehicle model
  - `year` (integer) - Manufacturing year
  - `fuel_type` (text) - 'petrol', 'diesel', 'electric', 'hybrid'
  - `condition` (text) - 'excellent', 'good', 'fair'
  - `mileage` (integer) - Total mileage in KM
  - `hourly_rate` (decimal) - Hourly rental rate (nullable for sell)
  - `daily_rate` (decimal) - Daily rental rate (nullable for sell)
  - `sale_price` (decimal) - Sale price (nullable for rent)
  - `location_lat` (decimal) - Latitude
  - `location_lng` (decimal) - Longitude
  - `location_address` (text) - Human-readable address
  - `insurance_available` (boolean) - Insurance option available
  - `insurance_rate` (decimal) - Insurance fee percentage (default 10%)
  - `is_available` (boolean) - Currently available for booking
  - `rating` (decimal) - Average vehicle rating
  - `total_bookings` (integer) - Total bookings count
  - `description` (text) - Vehicle description
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)
  
  ### 3. vehicle_photos
  - `id` (uuid, primary key)
  - `vehicle_id` (uuid, foreign key) - References vehicles.id
  - `photo_url` (text) - Photo URL
  - `order_index` (integer) - Display order
  - `created_at` (timestamptz)
  
  ### 4. bookings
  - `id` (uuid, primary key)
  - `vehicle_id` (uuid, foreign key) - References vehicles.id
  - `renter_id` (uuid, foreign key) - References users.id
  - `owner_id` (uuid, foreign key) - References users.id
  - `booking_type` (text) - 'hourly' or 'daily'
  - `start_time` (timestamptz) - Booking start
  - `end_time` (timestamptz) - Booking end
  - `duration_hours` (integer) - Total hours
  - `base_amount` (decimal) - Base rental amount
  - `insurance_added` (boolean) - Insurance included
  - `insurance_amount` (decimal) - Insurance fee
  - `total_amount` (decimal) - Total payment
  - `payment_method` (text) - 'bkash', 'nagad', 'wallet'
  - `payment_status` (text) - 'pending', 'completed', 'failed'
  - `booking_status` (text) - 'pending', 'active', 'completed', 'cancelled'
  - `current_lat` (decimal) - Real-time tracking latitude
  - `current_lng` (decimal) - Real-time tracking longitude
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)
  
  ### 5. messages
  - `id` (uuid, primary key)
  - `sender_id` (uuid, foreign key) - References users.id
  - `receiver_id` (uuid, foreign key) - References users.id
  - `vehicle_id` (uuid, foreign key, nullable) - References vehicles.id
  - `booking_id` (uuid, foreign key, nullable) - References bookings.id
  - `message_text` (text) - Message content
  - `is_read` (boolean) - Read status
  - `created_at` (timestamptz)
  
  ### 6. reviews
  - `id` (uuid, primary key)
  - `booking_id` (uuid, foreign key) - References bookings.id
  - `reviewer_id` (uuid, foreign key) - References users.id
  - `reviewed_user_id` (uuid, foreign key) - References users.id
  - `vehicle_id` (uuid, foreign key) - References vehicles.id
  - `rating` (integer) - Star rating (1-5)
  - `comment` (text) - Review text
  - `created_at` (timestamptz)
  
  ### 7. notifications
  - `id` (uuid, primary key)
  - `user_id` (uuid, foreign key) - References users.id
  - `title` (text) - Notification title
  - `body` (text) - Notification body
  - `type` (text) - 'booking', 'message', 'payment', 'kyc'
  - `reference_id` (uuid, nullable) - Related entity ID
  - `is_read` (boolean) - Read status
  - `created_at` (timestamptz)
  
  ### 8. wallet_transactions
  - `id` (uuid, primary key)
  - `user_id` (uuid, foreign key) - References users.id
  - `amount` (decimal) - Transaction amount (+ for credit, - for debit)
  - `transaction_type` (text) - 'deposit', 'withdrawal', 'payment', 'refund'
  - `reference_id` (uuid, nullable) - Related booking/payment ID
  - `description` (text) - Transaction description
  - `created_at` (timestamptz)
  
  ## Security
  - Enable RLS on all tables
  - Users can read their own data
  - Users can update their own profiles
  - Vehicle owners can manage their vehicles
  - Authenticated users can view public vehicle listings
  - Only booking participants can view booking details
  - Messages are private between sender and receiver
*/

-- Create users table (extends auth.users)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE,
  phone text UNIQUE,
  full_name text NOT NULL DEFAULT '',
  profile_photo text,
  kyc_status text NOT NULL DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'approved', 'rejected')),
  nid_card_url text,
  license_url text,
  nid_number text,
  license_number text,
  wallet_balance decimal(10,2) NOT NULL DEFAULT 0.00,
  rating decimal(3,2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
  total_reviews integer DEFAULT 0,
  language_preference text DEFAULT 'en' CHECK (language_preference IN ('en', 'bn')),
  dark_mode boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('car', 'bike')),
  listing_type text NOT NULL CHECK (listing_type IN ('rent', 'sell')),
  brand text NOT NULL,
  model text NOT NULL,
  year integer NOT NULL,
  fuel_type text CHECK (fuel_type IN ('petrol', 'diesel', 'electric', 'hybrid')),
  condition text CHECK (condition IN ('excellent', 'good', 'fair')),
  mileage integer DEFAULT 0,
  hourly_rate decimal(10,2),
  daily_rate decimal(10,2),
  sale_price decimal(10,2),
  location_lat decimal(10,8) NOT NULL,
  location_lng decimal(11,8) NOT NULL,
  location_address text NOT NULL,
  insurance_available boolean DEFAULT false,
  insurance_rate decimal(5,2) DEFAULT 10.00,
  is_available boolean DEFAULT true,
  rating decimal(3,2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
  total_bookings integer DEFAULT 0,
  description text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create vehicle_photos table
CREATE TABLE IF NOT EXISTS vehicle_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  photo_url text NOT NULL,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  renter_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  owner_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  booking_type text NOT NULL CHECK (booking_type IN ('hourly', 'daily')),
  start_time timestamptz NOT NULL,
  end_time timestamptz NOT NULL,
  duration_hours integer NOT NULL,
  base_amount decimal(10,2) NOT NULL,
  insurance_added boolean DEFAULT false,
  insurance_amount decimal(10,2) DEFAULT 0.00,
  total_amount decimal(10,2) NOT NULL,
  payment_method text CHECK (payment_method IN ('bkash', 'nagad', 'wallet')),
  payment_status text DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed')),
  booking_status text DEFAULT 'pending' CHECK (booking_status IN ('pending', 'active', 'completed', 'cancelled')),
  current_lat decimal(10,8),
  current_lng decimal(11,8),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  receiver_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vehicle_id uuid REFERENCES vehicles(id) ON DELETE SET NULL,
  booking_id uuid REFERENCES bookings(id) ON DELETE SET NULL,
  message_text text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reviewed_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  vehicle_id uuid NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  type text NOT NULL CHECK (type IN ('booking', 'message', 'payment', 'kyc')),
  reference_id uuid,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create wallet_transactions table
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount decimal(10,2) NOT NULL,
  transaction_type text NOT NULL CHECK (transaction_type IN ('deposit', 'withdrawal', 'payment', 'refund')),
  reference_id uuid,
  description text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_vehicles_type ON vehicles(type);
CREATE INDEX IF NOT EXISTS idx_vehicles_listing_type ON vehicles(listing_type);
CREATE INDEX IF NOT EXISTS idx_vehicles_owner ON vehicles(owner_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_location ON vehicles(location_lat, location_lng);
CREATE INDEX IF NOT EXISTS idx_bookings_renter ON bookings(renter_id);
CREATE INDEX IF NOT EXISTS idx_bookings_owner ON bookings(owner_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user ON wallet_transactions(user_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Public users can view other users basic info"
  ON users FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for vehicles table
CREATE POLICY "Anyone can view available vehicles"
  ON vehicles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Owners can insert their own vehicles"
  ON vehicles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their own vehicles"
  ON vehicles FOR UPDATE
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their own vehicles"
  ON vehicles FOR DELETE
  TO authenticated
  USING (auth.uid() = owner_id);

-- RLS Policies for vehicle_photos table
CREATE POLICY "Anyone can view vehicle photos"
  ON vehicle_photos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Vehicle owners can insert photos"
  ON vehicle_photos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = vehicle_photos.vehicle_id
      AND vehicles.owner_id = auth.uid()
    )
  );

CREATE POLICY "Vehicle owners can delete photos"
  ON vehicle_photos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM vehicles
      WHERE vehicles.id = vehicle_photos.vehicle_id
      AND vehicles.owner_id = auth.uid()
    )
  );

-- RLS Policies for bookings table
CREATE POLICY "Users can view their own bookings as renter"
  ON bookings FOR SELECT
  TO authenticated
  USING (auth.uid() = renter_id OR auth.uid() = owner_id);

CREATE POLICY "Users can create bookings as renter"
  ON bookings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = renter_id);

CREATE POLICY "Users can update their related bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (auth.uid() = renter_id OR auth.uid() = owner_id)
  WITH CHECK (auth.uid() = renter_id OR auth.uid() = owner_id);

-- RLS Policies for messages table
CREATE POLICY "Users can view their messages"
  ON messages FOR SELECT
  TO authenticated
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can update their received messages"
  ON messages FOR UPDATE
  TO authenticated
  USING (auth.uid() = receiver_id)
  WITH CHECK (auth.uid() = receiver_id);

-- RLS Policies for reviews table
CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create reviews for their bookings"
  ON reviews FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = reviewer_id);

-- RLS Policies for notifications table
CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for wallet_transactions table
CREATE POLICY "Users can view their own transactions"
  ON wallet_transactions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own transactions"
  ON wallet_transactions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();