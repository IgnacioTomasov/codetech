

return {

    contract_intro = {

        pages = {

            {
                text = "Bienvenido a Codetech... \n"..
                "Antes de ingresar, se requiere que firmes el contrato de confidencialidad.   "
            },
            {
                text = "Las consecuencias por divulgar información de la empresa son severas.\n"..
                "Se te hace un nudo en el estómago. Repentinamiente, te sientes culpado...",
            },
            {
                text = "¿Por qué serán así de estrictos? te preguntas...\n"..
                "Respiras hondo."
            },
            {
                text = "¿Deseas firmar?",

                options = {

                    {
                        text = "Aceptar",

                        flags = {
                            contract_signed = true,
                            office_access = true,
                        },

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