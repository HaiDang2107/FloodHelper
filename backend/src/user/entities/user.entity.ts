import { 
    Entity, PrimaryGeneratedColumn, Column, CreateDateColumn
} from 'typeorm';
import { UserRole } from 'src/common/userRole.enum';

// ---------------------------------------------------------
// User Entity
// ---------------------------------------------------------
@Entity()
export class User {
    @PrimaryGeneratedColumn('uuid')
    user_id: string;

    @Column({ type: 'enum', enum: UserRole, default: UserRole.GUEST })
    role: UserRole;

    @Column({ length: 50, nullable: false })
    first_name: string;

    @Column({ length: 50, nullable: false })
    last_name: string;

    @Column({ length: 100, nullable: true })
    display_name: string;

    @Column({ type: 'date', nullable: true })
    date_of_birth: Date;

    @Column({ nullable: true })
    village: string;

    @Column({ nullable: true })
    district: string;

    @Column({ nullable: true })
    province: string;

    @Column({ nullable: true })
    nation: string;

    @Column({ nullable: true })
    job_position: string;

    @Column({ nullable: true })
    avatar_img_link: string;

    @Column({ unique: true, nullable: true }) 
    citizen_id: string;

    @Column({ nullable: true })
    citizen_id_card_img_link: string;

    @Column({ default: false })
    public_map_mode: boolean;

    // Decimal with precision for coordinates
    @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
    cur_longitude: number;

    @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
    cur_latitude: number;
}