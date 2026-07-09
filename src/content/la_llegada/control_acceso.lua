

return {

    contract_intro = {

        pages = {

            {
                text = "Bienvenido a Codetech, {player_name}, lees sobre un papel digital instalado junto la entrada.\n"..
                "Antes de ingresar, se requiere que firmes el contrato de confidencialidad.   "
            },
            {
                text = "Varias páginas de texto explican gravemente las consecuencias por divulgar información de la empresa.\n"..
                "Se te hace un nudo en el estómago. Te sientes señalado, como si ya te estuvieran culpado por algo. Sin embargo, te calmas, confias en tu honestidad...",
            },
            {
                text = "¿Serán así de estrictos en todos los trabajos? te preguntas...\n"..
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
                            tutorial_completed = true,
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