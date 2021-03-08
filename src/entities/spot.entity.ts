import {BaseEntity, Column, Entity, OneToMany, PrimaryGeneratedColumn} from 'typeorm';
import {Track} from "./track.entity";
import {Guarded} from "./guarded.entity";

@Entity('MAD_T_Spot')
export class Spot extends BaseEntity {
    @PrimaryGeneratedColumn('uuid')
    sid: string;

    @Column({nullable: false})
    nameidentity: string;

    @Column({nullable: false})
    address: string;

    @Column({nullable: true})
    capacity: number;

    @OneToMany(() => Track, t => t.spot)
    tracks: Track[];

    @OneToMany(() => Guarded, g => g.spot)
    guards: Guarded[];
}