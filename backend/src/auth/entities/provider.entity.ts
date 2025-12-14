import { 
    Entity, PrimaryGeneratedColumn, Column
} from 'typeorm';
// ---------------------------------------------------------
// Provider Entity (Category)
// ---------------------------------------------------------
@Entity()
export class Provider {
    @PrimaryGeneratedColumn('uuid')
    provider_id: string;

    @Column({ unique: true })
    provider_name: string; // e.g., 'Google', 'Facebook'
}