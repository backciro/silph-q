import {BaseEntity, Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Timestamp} from 'typeorm';
import {Spot} from "./spot.entity";

@Entity('DBL_C_Guard')
export class Guarded extends BaseEntity {
    @PrimaryGeneratedColumn('uuid')
    gid: string;

    @Column({nullable: false})
    pubkey: string;

    @Column()
    checkin: Date;

    @Column({nullable: true})
    checkout: Date;

    @ManyToOne(() => Spot, spot => spot.tracks)
    @JoinColumn({name: 'spot'})
    spot: Spot;
}