import {BaseEntity, Column, Entity, PrimaryGeneratedColumn} from 'typeorm';

@Entity('MAD_T_PubKey')
export class PubKey extends BaseEntity {
    @PrimaryGeneratedColumn('uuid')
    pid: string;

    @Column({nullable: false})
    defcon: number;

    @Column({unique: true})
    pubkey: string;
}