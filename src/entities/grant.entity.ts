import {BaseEntity, Column, Entity, PrimaryGeneratedColumn} from 'typeorm';

@Entity('USR_T_Grant')
export class Grant extends BaseEntity {
    @PrimaryGeneratedColumn('uuid')
    gid: string;

    @Column({nullable: false})
    emailReference: string;

    @Column()
    fullName: string;

    @Column({nullable: true, default: 'it-IT'})
    locale: string;

    @Column({nullable: true})
    expiration: Date;
}