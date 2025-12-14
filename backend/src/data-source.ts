import "reflect-metadata"
import "dotenv/config" 
import { DataSource } from "typeorm"
import { User } from "./user/entities/user.entity"
import { Account } from "./auth/entities/account.entity"
import { AccountStateLog } from "./auth/entities/accountStateLog.entity"
import { Session } from "./auth/entities/session.entity"
import { Provider } from "./auth/entities/provider.entity"

export const AppDataSource = new DataSource({
    type: "postgres",
    url: process.env.DATABASE_URL, 
    synchronize: true,
    logging: false,
    // entities: [User, Account, AccountStateLog, Session, Provider],
    entities: [__dirname + "/entity/*.{js,ts}"],
    ssl: {
        rejectUnauthorized: false
    }
})