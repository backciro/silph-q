import {BaseEntity, Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Timestamp} from 'typeorm';
import {Spot} from "./spot.entity";

@Entity('BIG_F_Track')
export class Track extends BaseEntity {
    @PrimaryGeneratedColumn('uuid')
    tid: string;

    @Column({nullable: false})
    pubkey: string;

    @Column()
    timestamp: Date;

    @ManyToOne(() => Spot, spot => spot.tracks)
    @JoinColumn({name: 'spot'})
    spot: Spot;
}