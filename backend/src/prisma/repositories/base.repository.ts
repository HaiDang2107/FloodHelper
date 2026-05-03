/**
 * Base Repository Interface - Common CRUD operations
 * All repositories should extend this pattern for consistency
 */
export interface IBaseRepository<T> {
  /**
   * Find entity by unique identifier
   */
  findById(id: string): Promise<T | null>;

  /**
   * Find all entities with optional filtering
   */
  findAll(where?: any, options?: { skip?: number; take?: number }): Promise<T[]>;

  /**
   * Create new entity
   */
  create(data: any): Promise<T>;

  /**
   * Update existing entity
   */
  update(id: string, data: any): Promise<T>;

  /**
   * Delete entity
   */
  delete(id: string): Promise<T>;

  /**
   * Count entities matching criteria
   */
  count(where?: any): Promise<number>;
}

/**
 * Abstract Base Repository - Provides logging and common utilities
 * Extend this class to automatically get these capabilities
 */
export abstract class BaseRepository<T> implements IBaseRepository<T> {
  protected readonly entityName: string;

  constructor(entityName: string) {
    this.entityName = entityName;
  }

  abstract findById(id: string): Promise<T | null>;
  abstract findAll(where?: any, options?: { skip?: number; take?: number }): Promise<T[]>;
  abstract create(data: any): Promise<T>;
  abstract update(id: string, data: any): Promise<T>;
  abstract delete(id: string): Promise<T>;
  abstract count(where?: any): Promise<number>;

  /**
   * Helper for logging during development
   */
  protected log(operation: string, details?: any): void {
    if (process.env.NODE_ENV === 'development') {
      console.debug(`[${this.entityName}] ${operation}`, details);
    }
  }
}
