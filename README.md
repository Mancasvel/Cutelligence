# Cutelligence - Smart Barber App

A Flutter application for barbers to analyze client face shapes and recommend suitable haircuts.

## Features

- **User Authentication**: Email and password login/registration for barbers
- **Face Analysis**: Take or upload a photo to analyze face shape
- **Haircut Recommendations**: Get personalized haircut recommendations based on face shape
- **Client History**: View past client analyses and recommendations

## Funcionalidades específicas para Android

- Captura de fotos con la cámara
- Selección de imágenes desde la galería
- Análisis facial con Google ML Kit
- Almacenamiento en Supabase Storage

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase (Auth, Database, Storage)
- **Face Analysis**: Google ML Kit (face detection)

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Supabase account
- Android Studio or VS Code

### Supabase Setup

1. Create a new Supabase project
2. Set up the following tables:

**barbers table:**
```sql
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
```

**clients table:**
```sql
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
```

3. Create a storage bucket named "rostros" with appropriate RLS policies

### App Configuration

1. Clone the repository:
```
git clone https://github.com/yourusername/cutelligence.git
cd cutelligence
```

2. Configurar credenciales de Supabase:
   - Crea un archivo `lib/config/supabase_secrets.dart` con el siguiente contenido:
   ```dart
   class SupabaseSecrets {
     static const String supabaseUrl = 'TU_URL_DE_SUPABASE';
     static const String supabaseAnonKey = 'TU_CLAVE_ANON_DE_SUPABASE';
   }
   ```
   - Reemplaza `TU_URL_DE_SUPABASE` y `TU_CLAVE_ANON_DE_SUPABASE` con tus credenciales reales.

3. Install dependencies:
```
flutter pub get
```

4. Para ejecutar en el simulador de Android:
```
flutter run -d android
```

## Project Structure

- **lib/screens/**: UI screens
- **lib/services/**: Business logic and API services
- **lib/widgets/**: Reusable UI components
- **lib/models/**: Data models
- **lib/utils/**: Utility functions

## Future Enhancements

- More accurate face shape detection
- Custom haircut recommendations with AI
- Appointment booking for clients
- Social sharing of recommendations
- Before/after photo comparisons

## License

This project is licensed under the MIT License - see the LICENSE file for details.