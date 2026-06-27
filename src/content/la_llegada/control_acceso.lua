

return {

    contract_intro = {

        pages = {

            {
                text = "Bienvenido a Codetech."
            },

            {
                text = "¿Deseas firmar?",

                options = {

                    {
                        text = "Aceptar",

                        flags = {
                            contract_signed = true,
                            office_access = true,
                            tutorial_completed = true,
                        },

                        -- Se implementará en una siguiente iteración.
                        -- nextDialog = "la_llegada/control_acceso:contract_accept"
                    },

                    {
                        text = "Rechazar",

                        flags = {
                            contract_rejected = true,
                        },

                        gotoDialog = "la_llegada/control_acceso:contract_reject"
                    }

                }

            }

        }

    }, 

    contract_reject = {

        pages = {
            {
                text = "Lamentamos que no desees formar parte de Codetech."
            }
        }

    }


}