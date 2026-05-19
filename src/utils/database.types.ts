export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      metrics: {
        Row: {
          default_weight: number
          id: number
          key: string
          label: string
          sort_order: number
        }
        Insert: {
          default_weight: number
          id?: number
          key: string
          label: string
          sort_order: number
        }
        Update: {
          default_weight?: number
          id?: number
          key?: string
          label?: string
          sort_order?: number
        }
        Relationships: []
      }
      parks: {
        Row: {
          area_acres: number | null
          established: number | null
          id: number
          name: string
          nps_region: string | null
          slug: string
          states: string | null
        }
        Insert: {
          area_acres?: number | null
          established?: number | null
          id?: number
          name: string
          nps_region?: string | null
          slug: string
          states?: string | null
        }
        Update: {
          area_acres?: number | null
          established?: number | null
          id?: number
          name?: string
          nps_region?: string | null
          slug?: string
          states?: string | null
        }
        Relationships: []
      }
      ratings: {
        Row: {
          id: number
          metric_id: number
          park_id: number
          rated_at: string
          score: number
          user_id: string
        }
        Insert: {
          id?: number
          metric_id: number
          park_id: number
          rated_at?: string
          score: number
          user_id: string
        }
        Update: {
          id?: number
          metric_id?: number
          park_id?: number
          rated_at?: string
          score?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: 'ratings_metric_id_fkey'
            columns: ['metric_id']
            isOneToOne: false
            referencedRelation: 'metrics'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'ratings_park_id_fkey'
            columns: ['park_id']
            isOneToOne: false
            referencedRelation: 'aggregate_scores'
            referencedColumns: ['park_id']
          },
          {
            foreignKeyName: 'ratings_park_id_fkey'
            columns: ['park_id']
            isOneToOne: false
            referencedRelation: 'parks'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'ratings_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['id']
          }
        ]
      }
      user_park_ratings: {
        Row: {
          id: number
          last_visit_date: string | null
          notes: string | null
          park_id: number
          user_id: string
        }
        Insert: {
          id?: number
          last_visit_date?: string | null
          notes?: string | null
          park_id: number
          user_id: string
        }
        Update: {
          id?: number
          last_visit_date?: string | null
          notes?: string | null
          park_id?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: 'visits_park_id_fkey'
            columns: ['park_id']
            isOneToOne: false
            referencedRelation: 'aggregate_scores'
            referencedColumns: ['park_id']
          },
          {
            foreignKeyName: 'visits_park_id_fkey'
            columns: ['park_id']
            isOneToOne: false
            referencedRelation: 'parks'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'visits_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['id']
          }
        ]
      }
      user_weights: {
        Row: {
          id: number
          metric_id: number
          user_id: string
          weight: number
        }
        Insert: {
          id?: number
          metric_id: number
          user_id: string
          weight: number
        }
        Update: {
          id?: number
          metric_id?: number
          user_id?: string
          weight?: number
        }
        Relationships: [
          {
            foreignKeyName: 'user_weights_metric_id_fkey'
            columns: ['metric_id']
            isOneToOne: false
            referencedRelation: 'metrics'
            referencedColumns: ['id']
          },
          {
            foreignKeyName: 'user_weights_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['id']
          }
        ]
      }
      users: {
        Row: {
          created_at: string
          fingerprint: string | null
          id: string
          last_seen: string
          theme: string | null
        }
        Insert: {
          created_at?: string
          fingerprint?: string | null
          id?: string
          last_seen?: string
          theme?: string | null
        }
        Update: {
          created_at?: string
          fingerprint?: string | null
          id?: string
          last_seen?: string
          theme?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      aggregate_scores: {
        Row: {
          aggregate_score: number | null
          park_id: number | null
          park_name: string | null
          park_slug: string | null
          rater_count: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      find_user_by_fingerprint: {
        Args: { p_fingerprint: string }
        Returns: string
      }
      set_app_user_id: { Args: never; Returns: undefined }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, 'public'>]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])
    : never = never
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema['Tables'] &
        DefaultSchema['Views'])
    ? (DefaultSchema['Tables'] &
        DefaultSchema['Views'])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema['Enums']
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums']
    : never = never
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums'][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema['Enums']
    ? DefaultSchema['Enums'][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema['CompositeTypes']
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes']
    : never = never
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes'][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema['CompositeTypes']
    ? DefaultSchema['CompositeTypes'][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {}
  },
  public: {
    Enums: {}
  }
} as const

export interface ParkScore {
  park_id: number
  park_name: string
  park_slug: string
  rater_count: number
  aggregate_score: number
  rank: number
}
