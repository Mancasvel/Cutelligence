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

## Guía de inicio rápido

Sigue estos pasos para configurar y ejecutar la aplicación:

### 1. Configuración del entorno de desarrollo

1. **Instalar Flutter SDK**:
   - Descarga e instala Flutter desde [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Ejecuta `flutter doctor` y resuelve cualquier problema que se indique

2. **Configurar Android Studio y el SDK de Android**:
   - Instala [Android Studio](https://developer.android.com/studio)
   - Instala el SDK de Android y las herramientas de desarrollo
   - Configura un emulador Android o conecta un dispositivo físico

3. **Configurar Visual Studio Code (opcional)**:
   - Instala la extensión Flutter para VS Code

### 2. Configurar el proyecto

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/yourusername/cutelligence.git
   cd cutelligence
   ```

2. **Configurar credenciales de Supabase**:
   - Crea una cuenta en [Supabase](https://supabase.com/)
   - Crea un nuevo proyecto en Supabase
   - Crea un archivo `lib/config/supabase_secrets.dart` con tus credenciales:
   ```dart
   class SupabaseSecrets {
     static const String supabaseUrl = 'TU_URL_DE_SUPABASE';
     static const String supabaseAnonKey = 'TU_CLAVE_ANON_DE_SUPABASE';
   }
   ```

3. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

4. **Verificar conexión con el dispositivo**:
   ```bash
   flutter devices
   ```

### 3. Configurar la base de datos en Supabase

1. **Crear las tablas necesarias** (desde el dashboard de Supabase):
   - Tabla `barbers` - Ver SQL abajo
   - Tabla `clients` - Ver SQL abajo

2. **Configurar el Storage en Supabase**:
   - Crear un bucket llamado "rostros"
   - Configurar las políticas RLS para permitir acceso a usuarios autenticados

3. **Configurar autenticación**:
   - Habilitar la autenticación por correo/contraseña en Supabase

### 4. Ejecutar la aplicación

1. **Ejecutar en emulador o dispositivo Android**:
   ```bash
   flutter run -d android
   ```

2. **Para generar un APK de prueba**:
   ```bash
   flutter build apk --debug
   ```
   El APK estará disponible en `build/app/outputs/flutter-apk/app-debug.apk`

3. **Para generar un APK de release**:
   ```bash
   flutter build apk
   ```

### 5. Solución de problemas comunes

- **Error de conexión con Supabase**: Verifica que las credenciales en `supabase_secrets.dart` sean correctas
- **Error de cámara en emulador**: Algunos emuladores tienen problemas con la cámara, prueba con un dispositivo físico
- **Problemas con ML Kit**: Asegúrate de que tu emulador/dispositivo tenga Google Play Services actualizados

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

3. Create a storage bucket named "rostros" with appropriate RLS policies:
   ```sql
   -- Enable RLS on the storage.objects table
   alter table storage.objects enable row level security;

   -- Create policy for authenticated users to upload files
   create policy "Authenticated users can upload files to rostros bucket"
   on storage.objects for insert
   with check (bucket_id = 'rostros' and auth.role() = 'authenticated');

   -- Create policy for users to access their own files
   create policy "Users can access their own files in rostros bucket"
   on storage.objects for select
   using (bucket_id = 'rostros' and (storage.foldername(name))[1] = auth.uid()::text);
   ```

## Project Structure

- **lib/screens/**: UI screens
- **lib/services/**: Business logic and API services
- **lib/widgets/**: Reusable UI components
- **lib/models/**: Data models
- **lib/utils/**: Utility functions
- **lib/config/**: Configuration files

## Future Enhancements

- More accurate face shape detection
- Custom haircut recommendations with AI
- Appointment booking for clients
- Social sharing of recommendations
- Before/after photo comparisons

## License

This project is licensed under the MIT License - see the LICENSE file for details.