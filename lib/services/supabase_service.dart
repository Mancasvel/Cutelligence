import '../main.dart';

class SupabaseService {
  // Create a Supabase table structure for barbers
  static Future<void> createBarbersTable() async {
    // This function would typically be called once during initial setup
    // We're outlining what you need to manually create in the Supabase dashboard
    
    /*
    SQL for creating barbers table:
    
    create table public.barbers (
      id uuid references auth.users not null primary key,
      name text not null,
      email text not null unique,
      created_at timestamp with time zone default now() not null
    );
    
    -- Set up Row Level Security (RLS)
    alter table public.barbers enable row level security;
    
    -- Create policies
    create policy "Barbers can view their own profile" 
    on public.barbers for select 
    using (auth.uid() = id);
    
    create policy "Barbers can update their own profile" 
    on public.barbers for update 
    using (auth.uid() = id);
    */
  }

  // Create a Supabase table structure for clients
  static Future<void> createClientsTable() async {
    // This function would typically be called once during initial setup
    // We're outlining what you need to manually create in the Supabase dashboard
    
    /*
    SQL for creating clients table:
    
    create table public.clients (
      id uuid primary key default uuid_generate_v4(),
      barber_id uuid references public.barbers not null,
      fecha timestamp with time zone default now() not null,
      imagen_url text,
      forma_rostro text,
      recomendaciones jsonb,
      created_at timestamp with time zone default now() not null
    );
    
    -- Set up Row Level Security (RLS)
    alter table public.clients enable row level security;
    
    -- Create policies
    create policy "Barbers can view their own clients" 
    on public.clients for select 
    using (auth.uid() = barber_id);
    
    create policy "Barbers can insert their own clients" 
    on public.clients for insert 
    with check (auth.uid() = barber_id);
    
    create policy "Barbers can update their own clients" 
    on public.clients for update 
    using (auth.uid() = barber_id);
    */
  }

  // Create Supabase Storage buckets
  static Future<void> createStorageBuckets() async {
    // This function would typically be called once during initial setup
    // We're outlining what you need to manually create in the Supabase dashboard
    
    /*
    Steps to create storage bucket:
    
    1. Go to Storage in the Supabase dashboard
    2. Create a new bucket named 'rostros'
    3. Set the bucket privacy to 'authenticated' (or 'public' for testing)
    4. Create RLS policies to allow users to upload and view their own files
    
    Example RLS policy for uploads:
    
    create policy "Barbers can upload their own files"
    on storage.objects for insert
    with check (auth.uid()::text = (storage.foldername())[1]);
    
    Example RLS policy for viewing:
    
    create policy "Barbers can view their own files"
    on storage.objects for select
    using (auth.uid()::text = (storage.foldername())[1]);
    */
  }

  // Function to get current logged-in barber profile
  static Future<Map<String, dynamic>?> getCurrentBarber() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('barbers')
          .select()
          .eq('id', user.id)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Function to save client analysis
  static Future<void> saveClientAnalysis({
    required String imageUrl,
    required String faceShape,
    required List<String> recommendations,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('clients').insert({
      'barber_id': user.id,
      'imagen_url': imageUrl,
      'forma_rostro': faceShape,
      'recomendaciones': recommendations,
    });
  }

  // Function to get all client analysis for current barber
  static Future<List<Map<String, dynamic>>> getClientAnalysis() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('clients')
        .select()
        .eq('barber_id', user.id)
        .order('fecha', ascending: false);

    return (response as List).cast<Map<String, dynamic>>();
  }
} 