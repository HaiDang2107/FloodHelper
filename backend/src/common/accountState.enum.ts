export enum AccountState {
    ACTIVE = 'ACTIVE',
    INACTIVE = 'INACTIVE', // User registered but not verified, or soft deleted
    BANNED = 'BANNED',     // Admin action
}