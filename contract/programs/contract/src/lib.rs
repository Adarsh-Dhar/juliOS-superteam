use anchor_lang::prelude::*;

declare_id!("BEo6QRcNjibKhERUkVn6WaY9fwt1rmv8oc77x4Faog6L");

#[program]
pub mod contract {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}
