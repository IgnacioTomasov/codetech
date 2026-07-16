

return {

    librero_izquierdo_intro = {

        pages = {

            {
                text = "Libros anillados por doquier.",
                options = {
                    {
                        text = "Examinar",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:librero_izquierdo_primera_vista"
                    },
                    {
                        text = "Volver",
                    }
                }
            }
        }
    },

    librero_izquierdo_primera_vista = {

        pages = {
            {
                text = "Las carpetas parecen estar acumulándose desde hace siglos."

            },

            {
                text = "¿Dónde quisieras husmear?",
                options = {
                    {
                        text = "Explorar la carpeta antigua, la que tiene hojas de roneo.",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:explorar_carpeta_antigua"
                    },
                    {
                        text = "Explorar la carpeta de hojas sueltas.",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:explorar_carpeta_hojas_sueltas"
                    },
                    {
                        text = "Dejar de husmear."
                    }

                }
            }
        }
    },

    explorar_carpeta_antigua = {

        pages = {
            {
                text = "Hojas de roneo amarillentas, con tipografía de máquina de escribir. La tinta se ha corrido con el tiempo."
            },
            {
                text = "Algunas hojas tienen anotaciones a mano, con letra apretada y nerviosa.\nBocetos de ideas, quizás."
            },
            {
                text = "No hay nada que te llame la atención. Entonces ves palabras que te suenan familiar.",
                options = {
                    {
                        text = "Proyecto Trigo.",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:explicacion_trigo"
                    },
                    {
                        text = "Proyecto Vida.",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:explicacion_vida"
                    },
                    {
                        text = "Dejar de husmear."
                    }
                }
            }
        }
    },

    explorar_carpeta_hojas_sueltas = {

        pages = {
            {
                text = "Hojas sueltas, impresas hace apenas unos años. Muchas parecen haber sido arrancadas de informes internos."
            },
            {
                text = "Entre gráficos y tablas reconoces el nombre de un proyecto repetido una y otra vez.",
                options = {
                    {
                        text = "Proyecto CALMA.",
                        gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:explicacion_calma"
                    },
                    {
                        text = "Dejar de husmear."
                    }
                }
            }
        }
    },

    explicacion_calma = {

        pages = {
            {
                text = "Proyecto CALMA:\n"..
                "¿Cuánto de una decisión es realmente nuestra?"
            },
            {
                text = "¿Puede esta establecerse en un laboratorio?\nLa respuesta es sí."
            },
            {
                text = "CALMA estudia cómo pequeñas variaciones del entorno modifican el comportamiento. La intensidad de un sonido. La temperatura de una habitación. La demora de un ascensor."
            },
            {
                text = "La combinación correcta de estimulos pueden ser la llave para cambiar el curso de una decisión."
            },
            {
                text = "Comprender el ----------- es comprender la conducta."
            },
            {
                text = "El resto del documento ha sido completamente tachado.",
                gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:librero_izquierdo_intro"
            }
        },

    },

    explicacion_vida = {

        pages = {
            {
                text = "Proyecto VIDA: \n"..
                "La consciencia es una habilidad curiosa. La consciencia es una cualidad de la que todo objeto puede gozar. "
            },
            { 
                text = "Imagína si tu tostador pudiera hablar.\nImagina lo que tu --------------- te podría contar. "
            },
            { 
                text = "Una imagen vale más que mil palabras.\n"..
                "Un sentimiento vale una planilla de excel "
            },
            { 
                text = "Por eso el proyecto VIDA es una mina de oro. Se busca ----------------- -- -----------\n ---------- -- ----------- --- -------------- --- "
            }
            ,
            {
                text = "Las palabras tachadas te impiden seguir leyendo.",
                gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:librero_izquierdo_intro"
            }
        },

    },

    explicacion_trigo = {
        pages = {
            {
                text = "Proyecto TRIGO:\n"..
                "¿Qué habría ocurrido si el trigo nunca hubiese sido domesticado?"
            },
            {
                text = "TRIGO ejecuta simulaciones históricas completas donde la humanidad evoluciona. El trigo es solo un factor más."
            },
            {
                text = "Cada factor produce sociedades distintas. Un parámetro puede cambiar una civilización completa."
            },
            {
                text = "Comprender aquello que nunca ocurrió permite comprender mejor aquello que aún puede ocurrir."
            },
            {
                text = "El resto del documento ha sido cuidadosamente tachado.",
                gotoDialog = "la_llegada/primeras_pistas_en_la_biblioteca:librero_izquierdo_intro"
            }
        },
    }

}

