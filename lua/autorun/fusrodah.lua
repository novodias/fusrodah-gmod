if SERVER then
    CreateConVar("fusrodah_ragdoll_mass", 30, FCVAR_NONE, "Ragdoll mass")
    CreateConVar("fusrodah_distance", 150, FCVAR_NONE, "Entities that will be affected by the distance")
    CreateConVar("fusrodah_angle", 45, FCVAR_NONE, "Fus Ro Dah angle", 45, 90)
end

function playSound( ply )
    ply:EmitSound( "fusrodah/fusrodah.ogg", 500, 100, 0.5, CHAN_AUTO)
end

function fusCone( ply )
    local entities = ents.FindInCone(
        ply:EyePos(),
        ply:GetAimVector(),
        GetConVar("fusrodah_distance"):GetInt(),
        math.cos( math.rad( GetConVar("fusrodah_angle"):GetInt() ) )
    )

    playSound( ply )

    for id, tr in pairs(entities) do

        if (tr:GetModel() != nil) then
            if ( util.IsValidProp( tr:GetModel() ) ) then
                if ( not tr:IsValid() ) then tr:Remove() return end

                local aimvec = ply:GetAimVector()
                local pos = aimvec * 5
                pos:Add( tr:EyePos() )

                local phys = tr:GetPhysicsObject()
                if ( not phys:IsValid() ) then tr:Remove() return end

                aimvec:Mul( 100 )
                aimvec:Add( VectorRand( -10, 10 ) )
                phys:SetVelocity( aimvec * 100 )
            end
        else
            return
        end

        if ( tr:IsNPC() ) then
            local model = tr:GetModel()
            local ent = ents.Create( "prop_ragdoll" )

            if ( not ent:IsValid() ) then return end

            ent:SetModel( model )

            local aimvec = ply:GetAimVector()
            local pos = aimvec * 16
            pos:Add( tr:EyePos() )

            ent:SetPos( pos )
            ent:SetAngles( tr:EyeAngles() )
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if ( not phys:IsValid() ) then ent:Remove() return end

            aimvec:Mul( 100 )
            aimvec:Add( VectorRand( -10, 10 ) )
            phys:SetVelocity( aimvec * 2000 )

            -- Mass, the higher, longest the ragdoll will be throwed
            phys:SetMass( GetConVar("fusrodah_ragdoll_mass"):GetInt() )

            -- Removes the npc
            SafeRemoveEntity( tr )

            -- Timer of 30 seconds to remove the ragdoll
            timer.Simple( 30, function()
                SafeRemoveEntity( ent )
            end)
        end

        if ( tr:IsPlayer() ) then
            local model = tr:GetModel()
            local ent = ents.Create( "prop_ragdoll" )

            if ( not ent:IsValid() ) then return end

            ent:SetModel( model )

            local aimvec = ply:GetAimVector()
            local pos = aimvec * 16
            pos:Add( tr:EyePos() )

            ent:SetPos( pos )

            ent:SetAngles( tr:EyeAngles() )
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if ( not phys:IsValid() ) then ent:Remove() return end

            aimvec:Mul( 100 )
            aimvec:Add( VectorRand( -10, 10 ) )
            phys:SetVelocity( aimvec * 2000 )

            -- Mass, the higher, longest the ragdoll will be throwed
            phys:SetMass( GetConVar("fusrodah_ragdoll_mass"):GetInt() )

            tr:Spectate( OBS_MODE_CHASE )
            tr:SpectateEntity( ent )
            tr:StripWeapons()

            timer.Simple( 5, function()
                if IsValid(tr) then
                    tr:UnSpectate()
                    tr:Spawn()
                    tr:SetPos( ent:GetPos() )
                    SafeRemoveEntity( ent )
                end
            end)
        end

    end
end

hook.Add( "KeyPress", "FusrodahKey", function( ply, key)
    if ( key == IN_ZOOM ) then
        fusCone( ply )
    end
end)

concommand.Add("fusrodah", fusCone)