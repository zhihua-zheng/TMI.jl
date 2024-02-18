@testset "mass fractions" begin

    TMIversion = versionlist()[6] # G14 has no remote mass fractions
    #    TMIversion = "modern_90x45x33_G14"
    A, Alu, γ, TMIfile, L, B = config_from_nc(TMIversion);

    ϵ = 1e-10
    
    @testset "reading from matrix" begin
        m_north = TMI.massfractions_north(A, γ)

        @test maximum(m_north) < 1.0 + ϵ
        @test minimum(m_north) > 0.0 - ϵ
    end

    @testset "solve for matrix" begin

        for scenario in ("just determined","underdetermined")

            if scenario == "just determined"
                # get observations at surface
                # set them as surface boundary condition
                y = (θ =  readfield(TMIfile, "θ", γ),
                    S = readfield(TMIfile, "Sp", γ),
                    δ¹⁸O = readfield(TMIfile, "δ¹⁸Ow", γ),
                    P★ = preformedphosphate(TMIversion,Alu,γ),
                    δ¹³C★ = TMI.preformedcarbon13(TMIversion,Alu,γ)
                )
            elseif scenario == "underdetermined"
                y = (θ =  readfield(TMIfile, "θ", γ),
                    S = readfield(TMIfile, "Sp", γ),
                )
            end

            m̃ = massfractions(y)
            Ã = watermassmatrix(m̃, γ)

            # compare m̃ and m_true (Δ̄ = 1e-14 in my case)
            for nn in keys(m̃)
                Δ = m̃[nn]
                @test maximum(m̃[nn]) < 1.0 + ϵ
                @test minimum(m̃[nn]) > 0.0 - ϵ
            end

            bθ = getsurfaceboundary(y.θ)
            Ãlu = lu(Ã)
            θ̃ = steadyinversion(Ã,bθ,γ)

            # compare to c.θ
            maxmisfit = 0.05
            @test Base.maximum(y.θ - θ̃) < maxmisfit
            @test Base.minimum(y.θ - θ̃) > -maxmisfit


            # compare against the "truth" as solved by TMI
            m_true = (north = TMI.massfractions_north(A,γ),
                east   = TMI.massfractions_east(A,γ),
                south  = TMI.massfractions_south(A,γ),
                west   = TMI.massfractions_west(A,γ),
                up     = TMI.massfractions_up(A,γ),
                down   = TMI.massfractions_down(A,γ))

            #mc_test = TMI.tracer_contribution(y.θ,m_true.north) # a test
            mc_true = TMI.tracer_contribution(y.θ,m_true)
            @test maximum(mc_true) < 1e-6
            @test minimum(mc_true) > -1e-6

            mc_test = TMI.tracer_contribution(y.θ,m̃)
            @test maximum(mc_test) < 1e-3
            @test minimum(mc_test) > -1e-3
        end
    end
end
