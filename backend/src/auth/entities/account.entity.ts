import { 
    Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, 
    OneToOne, ManyToOne, JoinColumn 
} from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Provider } from './provider.entity';
import { AccountState } from '../../common/accountState.enum';

// ---------------------------------------------------------
// Account Entity
// ---------------------------------------------------------
@Entity()
export class Account {
    @PrimaryGeneratedColumn('uuid')
    account_id: string;

    // 1 User <-> 1 Account
    @OneToOne(() => User)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @ManyToOne(() => Provider, { nullable: true })
    @JoinColumn({ name: 'provider_id' })
    provider: Provider;

    // ID from the provider (e.g., Google Sub ID). Nullable for local accounts.
    @Column({ nullable: true })
    provider_user_id: string;

    @Column({ nullable: true, select: false }) // Hide token by default
    refresh_token_from_provider: string;

    @ManyToOne(() => User, { nullable: true })
    @JoinColumn({ name: 'create_by' })
    create_by: User;

    @Column({ unique: true, nullable: true })
    username: string;

    // WARNING: 'unique: true' for password is unconventional (see notes below)
    @Column({ select: false, unique: true, nullable: true }) 
    password: string;

    @Column({ type: 'enum', enum: AccountState, default: AccountState.INACTIVE })
    state: AccountState;

    @CreateDateColumn()
    create_at: Date;
}