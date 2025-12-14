import { 
    Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, 
    ManyToOne, JoinColumn 
} from 'typeorm';

import { Account } from './account.entity';
import { User } from '../../user/entities/user.entity';
import { AccountState } from '../../common/accountState.enum';

// ---------------------------------------------------------
// AccountStateLog Entity
// ---------------------------------------------------------
@Entity()
export class AccountStateLog {
    @PrimaryGeneratedColumn('uuid')
    log_id: string;

    @ManyToOne(() => Account)
    @JoinColumn({ name: 'account_id' })
    account: Account;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'changed_by' })
    changed_by: User;

    @CreateDateColumn()
    change_at: Date;

    @Column({ type: 'enum', enum: AccountState })
    new_state: AccountState;
}