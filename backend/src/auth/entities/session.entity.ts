import { 
    Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn 
} from 'typeorm';
import { Account } from './account.entity';

// ---------------------------------------------------------
// Session Entity
// ---------------------------------------------------------
@Entity()
export class Session {
    @PrimaryGeneratedColumn('uuid')
    session_id: string;

    @ManyToOne(() => Account)
    @JoinColumn({ name: 'account_id' })
    account: Account;

    @Column()
    refresh_token: string;

    @Column({ default: true })
    state: boolean; // true = active, false = revoked

    @Column({ nullable: true })
    device_id: string;

    @CreateDateColumn()
    create_at: Date;

    @Column()
    expire_at: Date;
}