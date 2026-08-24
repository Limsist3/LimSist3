CREATE OR REPLACE FUNCTION public.export_auth_users()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  result jsonb;
BEGIN
  IF NOT public.is_superadmin(auth.uid()) THEN
    RAISE EXCEPTION 'Apenas o superadministrador pode exportar contas';
  END IF;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'id', u.id,
    'email', u.email,
    'phone', u.phone,
    'encrypted_password', u.encrypted_password,
    'email_confirmed_at', u.email_confirmed_at,
    'phone_confirmed_at', u.phone_confirmed_at,
    'created_at', u.created_at,
    'raw_user_meta_data', u.raw_user_meta_data,
    'raw_app_meta_data', u.raw_app_meta_data
  )), '[]'::jsonb)
  INTO result
  FROM auth.users u
  WHERE u.deleted_at IS NULL;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.export_auth_users() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.export_auth_users() TO authenticated, service_role;